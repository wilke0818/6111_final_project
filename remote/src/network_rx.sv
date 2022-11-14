`timescale 1ns / 1ps
`default_nettype none

module network_rx #(parameter N=2) (
  input wire clk,
  input wire rst,
  input wire axiiv,
  input wire [N-1:0] axiid,
  input wire ethertype_in,
  output logic axiov,
  output logic [31:0] src_ip_out,
  output logic [31:0] dst_ip_out,
  output logic [7:0] ip_protocol_out,
  output logic [15:0] packet_length_out
);

  logic ip_axiiv, arp_axiiv, ip_axiov, arp_axiov;
  logic [N-1:0] ip_axiid, arp_axiid;
  logic [31:0] ip_src_ip, ip_dst_ip;
  logic [15:0] ip_packet_length;
  
  assign src_ip_out = ~ethertype_in ? ip_src_ip : 0;
  assign dst_ip_out = ~ethertype_in ? ip_dst_ip : 0;
  assign ip_axiiv = ~ethertype_in && axiiv;
  assign arp_axiiv = ethertype_in && axiiv;

  assign ip_axiid = ~ethertype_in ? axiid : 0;
  assign arp_axiid = ethertype_in ? axiid : 0;

  assign axiov = ethertype_in ? arp_axiov : ip_axiov;
  assign packet_length_out = ethertype_in ? 0 : ip_packet_length;

  internet_protocol_rx #(.N(N)) ip4(
    .clk(clk),
    .rst(rst),
    .axiiv(ip_axiiv),
    .axiid(ip_axiid),
    .axiov(ip_axiov),
    .src_ip_out(ip_src_ip),
    .dst_ip_out(ip_dst_ip),
    .protocol_out(ip_protocol_out),
    .packet_length_out(ip_packet_length)
  );

  arp_rx #(.N(N)) arp_mod(
    .clk(clk),
    .rst(rst),
    .axiiv(arp_axiiv),
    .axiid(arp_axiid),
    .axiov(arp_axiov)
  );

endmodule;

`default_nettype wire
