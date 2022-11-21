`timescale 1ns / 1ps
`default_nettype none



module transport_tx #(parameter N=2) (
  input wire clk,
  input wire rst,
  input wire axiiv,
  input wire [7:0] protocol_in,
  input wire [31:0] src_ip_in,
  input wire [31:0] dst_ip_in,
  input wire [15:0] data_length_in,
  input wire [15:0] data_checksum_in,
  input wire [15:0] udp_src_port_in,
  input wire [15:0] udp_dst_port_in,
  output logic axiov,
  output logic [N-1:0] axiod,
  output logic axi_last
  );

  logic udp_axiiv, udp_axiov, udp_axi_last;
  logic [N-1:0] udp_axiod;

  assign udp_axiiv = axiiv && protocol_in == 17;
 // assign udp_axiid = axiiv && protocol_in == 17 ? axiid : 0;

  assign axiov = protocol_in == 17 ? udp_axiov : 0; //fill in additional terneries later
  assign axiod = protocol_in == 17 ? udp_axiod : 0; //fill in additional terneries later
  assign axi_last = protocol_in == 17 ? udp_axi_last : 0; //fill in additional terneries later

  udp_tx #(.N(N)) udp_in(
    .clk(clk),
    .rst(rst),
    .axiiv(udp_axiiv),
    .src_ip_in(src_ip_in),
    .dst_ip_in(dst_ip_in),
    .data_length_in(data_length_in),
    .data_checksum_in(data_checksum_in),
    .dst_port_in(udp_dst_port_in),
    .src_port_in(udp_src_port_in),
    .axiov(udp_axiov),
    .axiod(udp_axiod),
    .axi_last(udp_axi_last)
  );

endmodule


`default_nettype wire
