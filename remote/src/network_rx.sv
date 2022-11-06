`timescale 1ns / 1ps
`default_nettype none

module network_rx #(parameter N=2) (
  input wire clk,
  input wire rst,
  input wire axiiv,
  input wire [N-1:0] axiid,
  input wire ethertype,
  output logic axiov,
  output logic [N-1:0] axiod
);

  logic ip_axiiv, arp_axiiv, ip_axiov, arp_axiov;
  logic [N-1:0] ip_axiid, arp_axiid, ip_axiod, arp_axiod;

  assign ip_axiiv = ~ethertype && axiiv;
  assign arp_axiiv = ethertype && axiiv;

  assign ip_axiid = ~ethertype ? axiid : 0;
  assign arp_axiid = ethertype ? axiid : 0;

  assign axiov = ethertype ? arp_axiov : ip_axiov;
  assign axiod = ethertype ? arp_axiod : ip_axiod;

  internet_protocol_rx #(.N(N)) ip4(
    .clk(clk),
    .rst(rst),
    .axiiv(ip_axiiv),
    .axiid(ip_axiid),
    .axiov(ip_axiov),
    .axiod(ip_axiod)
  );

  arp_rx #(.N(N)) arp_mod(
    .clk(clk),
    .rst(rst),
    .axiiv(arp_axiiv),
    .axiid(arp_axiid),
    .axiov(arp_axiov),
    .axiod(arp_axiod)
  );

endmodule;

`default_nettype wire
