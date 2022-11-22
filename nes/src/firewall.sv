`default_nettype none
`timescale 1ns / 1ps

module firewall #(parameter N=2) (
  input wire clk,
  input wire rst,
  input wire axiiv,
  input wire [N-1:0] axiid,
  input wire [47:0] my_mac,
  output logic axiov,
  output logic [N-1:0] axiod);

  parameter ALL_DEST = 48'hFFFFFFFFFFFF;
  parameter MAX_COUNT = 112/N;
  parameter COUNT_SRC = 96/N;
  parameter COUNT_DEST = 48/N;
  parameter COUNT_BITS = $clog2(MAX_COUNT);
//  parameter MY_MAC = 48'420420420420h; //remotenes.mit.edu (42:04:20:42:04:20)

  logic [47:0] mac;
  logic [COUNT_BITS-1:0] count;
  logic valid;
  
  assign axiod = axiid;
  assign axiov = rst ? 0 : valid && axiiv && count > COUNT_SRC-1;

  always_ff @(posedge clk) begin
    if (rst) begin
     // axiov <= 0;
      mac <= 0;
      count <= 0;
      valid <= 1;
    end else begin
      if (axiiv && valid) begin
        if (count < COUNT_DEST) begin
          mac[48-N*(count+1) +: N] = axiid;
          count <= count + 1;
        end else if (count == COUNT_DEST) begin
          if (mac != my_mac && mac != ALL_DEST) begin
            valid <= 0;
          end
          count <= count + 1;
        end else if (count < COUNT_SRC) begin
          count <= count+1;
        end
      end else begin
   //     axiov <= 0;
        count <= 0;
        valid <= ~axiiv;
      end
    end


  end

endmodule
`default_nettype wire

