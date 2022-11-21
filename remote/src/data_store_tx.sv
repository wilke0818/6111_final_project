`timescale 1ns / 1ps
`default_nettype none

module data_store_tx #(parameter N=2, parameter DATA_SIZE=16) (
  input wire clk,
  input wire rst,
  input wire axiiv,
  input wire [DATA_SIZE-1:0] axiid,
  input wire read_request,
  output logic axiov,
  output logic [N-1:0] axiod,
  output logic [15:0] data_cksum,
  output logic [15:0] data_length //will be in bytes
);

  logic [7:0] read_idx, write_idx;
  logic [$clog2(16/N)-1:0] read_count;
  logic [15:0] read_out;
  logic [8:0] bytes_written;
  logic [1:0] cycle_delay_start, cycle_delay_end;
  logic [16:0] sum;
  logic [15:0] word1, word2, word3, word4;

  logic [3:0] position;
  logic [1:0] cksum_count;

  logic [DATA_SIZE-1:0] read_data;

  assign data_cksum = ~sum;
  assign data_length = position > 8 ? (bytes_written<<1) + 2 : position > 0 ? (bytes_written<<1)+1 : bytes_written<<1;

  xilinx_true_dual_port_read_first_2_clock_ram #(
    .RAM_WIDTH(DATA_SIZE),                       // Specify RAM data width
    .RAM_DEPTH(256)                     // Specify RAM depth (number of entries)
  ) data_store(
  .addra(read_idx),  // Port A address bus, width determined from RAM_DEPTH
  .addrb(write_idx),  // Port B address bus, width determined from RAM_DEPTH
  .dina(),           // Port A RAM input data
  .dinb(axiid),           // Port B RAM input data
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
  .douta(read_data),         // Port A RAM output data
  .doutb()          // Port B RAM output data
);


  assign axiod = read_data[DATA_SIZE-1-N*read_count -: N];

  // Writing to the BRAM
  always_ff @(posedge clk) begin
    if (rst) begin
      write_idx <= 0;
      bytes_written <= 0;
      sum <= 0;
//      word_select <= 0;
      position <= 0;
      word1 <= 0;
      word2 <= 0;
      word3 <= 0;
      word4 <= 0;
      cksum_count <= 0;
    end else begin
      if (axiiv) begin 
        write_idx <= write_idx + 1;
        bytes_written <= position + DATA_SIZE > 15 ? bytes_written + 1 : bytes_written;
        
        if (cksum_count == 0) begin
           word1[15-position -: DATA_SIZE] <= axiid;
           cksum_count <= cksum_count + 1;
           position <= position + DATA_SIZE;
           sum <= word1 + word2 + word3 + word4;
           word2 <= 0;
           word3 <= 0;
           word4 <= 0;
        end else if (cksum_count == 1) begin
           word2[15-position -: DATA_SIZE] <= axiid;
           cksum_count <= cksum_count + 1;
           position <= position + DATA_SIZE;
           sum <= sum[15:0] + sum[16];
        end else if (cksum_count == 2) begin
           word3[15-position -: DATA_SIZE] <= axiid;
           cksum_count <= cksum_count + 1;
           position <= position + DATA_SIZE;
        end else begin
           word4[15-position -: DATA_SIZE] <= axiid;
           cksum_count <= cksum_count + 1;
           position <= position + DATA_SIZE;
        end  
      end
    end
  end

  //Reading from the BRAM
  always_ff @(posedge clk) begin
    if (rst) begin
      read_idx <= 0;
      axiov <= 0;
      read_count <= 0;
    end else begin
      if (read_request) begin
        axiov <= 1'b1;
        if (word1 + word2 + word3 + word4 > 17'b0_1111_1111_1111_1111) begin
          sum <= word1 + word2 + word3 + word4 + (word1 + word2 + word3 + word4)>>16;
        end else begin
          sum <= word1 + word2 + word3 + word4;
        end
        if (read_idx < write_idx) begin
          if (read_count < DATA_SIZE/N - 2) begin
            read_count <= read_count + 1;
          end else if (read_count < DATA_SIZE/N-1) begin
            read_count <= read_count + 1;
            read_idx <= read_idx + 1;
          end else begin
            read_count <= read_count + 1;
          end
        end
      end else begin
        axiov <= 0;
        read_idx <= 0;
        read_count <= 0;
      end
    end
  end

endmodule


`default_nettype wire
