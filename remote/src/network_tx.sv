`timescale 1ns / 1ps
`default_nettype none

module network_tx #(parameter N=2) (
  input wire clk,
  input wire rst,
  input wire axiiv,
  input wire [15:0] ethertype_in,
  output logic axiov,
  output logic [N-1:0] axiod,
  input wire [31:0] src_ip_in,
  input wire [31:0] dst_ip_in,
  input wire [7:0] ip_protocol_in,
  input wire [15:0] data_length_in,
  output logic axi_last
);

  logic ip_axiiv, arp_axiiv, ip_axiov, arp_axiov, ip_axi_last, arp_axi_last;
  logic [N-1:0] ip_axiod, arp_axiod;

  logic [15:0] transport_header_length;

  assign transport_header_length = ip_protocol_in == 8'h11 ? 16'h0008 : 0;
  
  assign ip_axiiv = ethertype_in == 16'h0800 && axiiv;
  assign arp_axiiv = ethertype_in == 16'h0860 && axiiv;

 // assign ip_axiid = ethertype_in == 16'h0800 ? axiid : 0;
 // assign arp_axiid = ethertype_in == 16'h0860 ? axiid : 0;

  assign axi_last = ethertype_in == 16'h0860 ? arp_axi_last : ethertype_in == 16'h0800 ? ip_axi_last : 0;
  assign axiov = ethertype_in == 16'h0860 ? arp_axiov : ethertype_in == 16'h0800 ? ip_axiov : 0;
  assign axiod = ethertype_in == 16'h0860 ? arp_axiod : ethertype_in == 16'h0800 ? ip_axiod : 0;
  //assign packet_length_out = ethertype_in ? 0 : ip_packet_length;

  internet_protocol_tx #(.N(N)) ip4_tx(
    .clk(clk),
    .rst(rst),
    .axiiv(ip_axiiv),
    .axiov(ip_axiov),
    .src_ip_in(src_ip_in),
    .dst_ip_in(dst_ip_in),
    .protocol_in(ip_protocol_in),
    .transport_header_length_in(transport_header_length),
    .data_length_in(data_length_in),
    .axi_last(ip_axi_last)
  );

endmodule

`default_nettype wire
