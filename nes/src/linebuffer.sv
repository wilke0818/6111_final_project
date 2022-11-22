`timescale 1ns / 1ps
`default_nettype none


module linebuffer
    ( input wire clk
    , input wire rst
    , input wire axiiv
    , input wire [23:0] axiid
    , output logic axiov
    , output logic axiod
    );
    
    logic [31:0] pixel_count; // Counts what hcount we're at. Could probably replace with hcount_in
    
    
    always_ff @(posedge clk)begin
        if(rst)begin
            pixel_count <= 0;
        end else begin
            // TODO: implement linebuffer
            // BRAM[0] <= vcount;
            // BRAM[pixel_count] <= axiid;
            pixel_count <= pixel_count + 1;
            // if (pixel_count >= 260)begin
                // axiov <= 1;
                // axiod <= BRAM[0-->260];
            //end
        end
    end

endmodule