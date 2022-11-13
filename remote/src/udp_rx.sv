`timescale 1ns / 1ps
`default_nettype none

module udp_rx #(parameter N=2) (
  input wire clk,
  input wire rst,
  input wire axiiv,
  input wire [N-1:0] axiid,
  input wire [31:0] src_ip_in,
  input wire [31:0] dst_ip_in,
  input wire [15:0] packet_length_in,
  output logic axiov
);



endmodule

`default_nettype wire
