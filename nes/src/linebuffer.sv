`timescale 1ns / 1ps
`default_nettype none


module linebuffer
    #(parameter LINE_WIDTH=260
    , parameter LINE_HEIGHT=256
    , parameter CAM_LINE_WIDTH=480)
    ( input wire clk
    , input wire rst
    , input wire axiiv
    // , input wire frame_reset
    , input wire [23:0] axiid
    , output logic axiov
    , output logic [11:0] axiod
    );
    
    logic [31:0] pixel_count; // Counts what hcount we're at. Could probably replace with hcount_in
    logic [8:0] i_read;
    logic [15:0] line_count = 0;
    logic sw = 0;

    logic [8:0] lineb1_addr;
    logic [11:0] lineb1_data_in;
    logic lineb1_valid;
    logic [11:0] lineb1_data_out;

    logic [8:0] lineb2_addr;
    logic [11:0] lineb2_data_in;
    logic lineb2_valid;
    logic [11:0] lineb2_data_out;

    logic [11:0] pixel_in;
    assign pixel_in = axiid[11:0];
    
    xilinx_single_port_ram_read_first #(
      .RAM_WIDTH(12),                       // Specify RAM data width
      .RAM_DEPTH(LINE_WIDTH),                     // Specify RAM depth (number of entries)
      .RAM_PERFORMANCE("HIGH_PERFORMANCE") // Select "HIGH_PERFORMANCE" or "LOW_LATENCY" 
    ) lineb1 (
      .addra(lineb1_addr),     // Address bus, width determined from RAM_DEPTH
      .dina(lineb1_data_in),       // RAM input data, width determined from RAM_WIDTH
      .clka(clk),       // Clock
      .wea(lineb1_valid),         // Write enable
      .ena(1'b1),         // RAM Enable, for additional power savings, disable port when not in use
      .rsta(1'b0),       // Output reset (does not affect memory contents)
      .regcea(1'b1),   // Output register enable
      .douta(lineb1_data_out)      // RAM output data, width determined from RAM_WIDTH
    );
      
    xilinx_single_port_ram_read_first #(
      .RAM_WIDTH(12),                       // Specify RAM data width
      .RAM_DEPTH(LINE_WIDTH),                     // Specify RAM depth (number of entries)
      .RAM_PERFORMANCE("HIGH_PERFORMANCE") // Select "HIGH_PERFORMANCE" or "LOW_LATENCY" 
    ) lineb2 (
      .addra(lineb2_addr),     // Address bus, width determined from RAM_DEPTH
      .dina(lineb2_data_in),       // RAM input data, width determined from RAM_WIDTH
      .clka(clk),       // Clock
      .wea(lineb2_valid),         // Write enable
      .ena(1'b1),         // RAM Enable, for additional power savings, disable port when not in use
      .rsta(1'b0),       // Output reset (does not affect memory contents)
      .regcea(1'b1),   // Output register enable
      .douta(lineb2_data_out)      // RAM output data, width determined from RAM_WIDTH
    );


    always_ff @(posedge clk)begin
        if(rst)begin
            pixel_count <= 0;
            i_read <= 999;
            sw <= 0;
            axiov <= 0;
            lineb1_valid <= 0;
            lineb2_valid <= 0;
            line_count <= 0;
        end else begin
            if (i_read <= LINE_WIDTH)begin
                axiov <= 1;
                if (sw) begin
                    lineb1_addr <= i_read;
                    axiod <= lineb1_data_out;
                end else begin
                    lineb2_addr <= i_read;
                    axiod <= lineb2_data_out;
                end
                i_read <= i_read + 1;
            end else begin
                axiov <= 0;
            end
            if (axiiv)begin
                if (pixel_count < LINE_WIDTH)begin
                    if (sw)begin
                        lineb2_valid <= 1;
                        lineb2_addr <= pixel_count;
                        lineb2_data_in <= pixel_in;
                    end else begin
                        lineb1_valid <= 1;
                        lineb1_addr <= pixel_count;
                        lineb1_data_in <= pixel_in;
                    end
                end else if (pixel_count == LINE_WIDTH)begin
                    sw <= ~sw;
                    if (line_count <= LINE_HEIGHT)begin
                        line_count <= line_count + 1;
                    end else begin
                        line_count <= 0;
                    end
                    axiov <= 1;
                    axiod <= line_count;
                    lineb1_valid <= 0;
                    lineb2_valid <= 0;
                end else begin
                    if (pixel_count == LINE_WIDTH + 1)
                        i_read <= 0;
                    if (pixel_count >= CAM_LINE_WIDTH)begin
                        pixel_count <= 0;
                    end
                end
                if (pixel_count < CAM_LINE_WIDTH)
                    pixel_count <= pixel_count + 1;
            end
            // TODO: implement linebuffer
            // BRAM[0] <= vcount;
            // BRAM[pixel_count] <= axiid;
            // if (pixel_count >= 260)begin
                // axiov <= 1;
                // axiod <= BRAM[0-->260];
            //end
        end
    end

endmodule
