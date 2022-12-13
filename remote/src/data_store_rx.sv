`timescale 1ns / 1ps
`default_nettype none

module data_store_rx #(parameter N=2) (
  input wire clk,
  input wire rst,
  input wire axiiv,
  input wire [N-1:0] axiid,
  input wire read_request,
  output logic axiov,
  output logic [15:0] axiod
);

  logic [7:0] read_idx, write_idx;
  logic [15:0] write_in; //handle the 32bit checksum
  logic [$clog2(16/N)-1:0] write_count;
  logic [15:0] read_out;
  logic [7:0] words_written, read_count;
  logic [1:0] cycle_delay_start, cycle_delay_end;

  logic prev_axiiv, prev_axiov;

  xilinx_true_dual_port_read_first_2_clock_ram #(
    .RAM_WIDTH(16),                       // Specify RAM data width
    .RAM_DEPTH(256)                     // Specify RAM depth (number of entries)
  ) data_store(
  .addra(read_idx),  // Port A address bus, width determined from RAM_DEPTH
  .addrb(write_idx),  // Port B address bus, width determined from RAM_DEPTH
  .dina(),           // Port A RAM input data
  .dinb({write_in[15:N], axiid}),           // Port B RAM input data
  .clka(clk),                           // Port A clock
  .clkb(clk),                           // Port B clock
  .wea(1'b0),                            // Port A write enable
  .web(axiiv), //only be able to write when valid data                           // Port B write enable
  .ena(1'b1),                            // Port A RAM Enable, for additional power savings, disable port when not in use
  .enb(1'b1),                            // Port B RAM Enable, for additional power savings, disable port when not in use
  .rsta(rst),                           // Port A output reset (does not affect memory contents)
  .rstb(rst),                           // Port B output reset (does not affect memory contents)
  .regcea(1'b1),                         // Port A output register enable
  .regceb(1'b1),                         // Port B output register enable
  .douta(axiod),         // Port A RAM output data
  .doutb()          // Port B RAM output data
);


  always_comb begin
    if (rst) begin
      words_written = 0;
    end else begin
      words_written = write_idx - 2;
    end
  end

  // Writing to the BRAM
  always_ff @(posedge clk) begin
    if (rst) begin
      write_idx <= 0;
      write_in <= 0;
     // words_written <= 0;
      write_count <= 0;
      prev_axiiv <= 0;
    end else begin
      prev_axiiv <= axiiv;
      if (axiiv) begin
        if (write_count < 16/N-1) begin
          write_in[15-write_count*N -: N] <= axiid;
          write_count <= write_count + 1;
        end else begin
          write_in[15-write_count*N -: N] <= axiid;
          write_count <= 0;
          write_idx <= write_idx + 1; 
        end
      end else begin
        if (~axiov && prev_axiov) begin
          write_idx <= 0;
          write_in <= 0;
          write_count <= 0;
        end
      end
    end
  end

  //Reading from the BRAM
  always_ff @(posedge clk) begin
    if (rst) begin
      read_idx <= 0;
      axiov <= 0;
      cycle_delay_start <= 2'd2;
      cycle_delay_end <= 0;
      prev_axiov <= 0;
    end else begin
      prev_axiov <= axiov;
      if (read_request) begin
        if (cycle_delay_start ==0) begin
          cycle_delay_end <= 0;
          if (read_idx < words_written) begin
            axiov <= 1'b1;
           // axiod <= read_out;
            read_idx <= read_idx + 1;
            
          end else if (cycle_delay_end < 1) begin
            cycle_delay_end <= cycle_delay_end + 1;
          end else begin
            axiov <= 0;
          end
        end else if (cycle_delay_start == 2) begin
          cycle_delay_start <= cycle_delay_start - 1;
          read_idx <= read_idx + 1;
        end else begin
          cycle_delay_end <= 0;
          cycle_delay_start <= cycle_delay_start - 1;
          read_idx <= read_idx + 1;
          axiov <= 1;
        end
      end else begin
        if (cycle_delay_end < 1) begin
          cycle_delay_end <= cycle_delay_end + 1;
        end else begin
          axiov <= 0;
          read_idx <= 0; 
          cycle_delay_start <= 2'd2;
        end
      end
    end
  end

endmodule


`default_nettype wire
