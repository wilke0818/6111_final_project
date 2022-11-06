`timescale 1ns / 1ps
`default_nettype none

module network_stack #(parameter N=2) (
  input wire clk, //clock @ 25 or 50 mhz
  input wire rst, //btnc (used for reset)
  input wire [N-1:0] eth_rxd,
  input wire eth_crsdv,
  input wire [47:0] mac,
  output logic eth_txen,
  output logic [N-1:0] eth_txd
  );

  logic ethernet_axiod;
  logic [N-1:0] ordered_eth_rxd;
  logic rx_kill, rx_done, ethernet_axiov, ordered_eth_crsdv;

  ethernet_rx #(.N(N)) ethernet_in(
    .clk(clk),
    .rst(rst),
    .axiid(eth_rxd),
    .axiiv(eth_crsdv),
    .mac(mac),
    .axiod(ethernet_axiod),
    .axiov(ethernet_axiov),
    .rx_done(rx_done),
    .rx_kill(rx_kill)
  );

  bitorder #(.N(N)) bitmod( //Kinda redundant but helps encapsulate ethernet logic
    .clk(clk),
    .rst(rst),
    .axiid(eth_rxd),
    .axiiv(ethernet_axiov && eth_crsdv),
    .axiod(ordered_eth_rxd),
    .axiov(ordered_eth_crsdv));


  network_rx #(.N(N)) network_in(
    .clk(clk),
    .rst(rst),
    .ethertype(ethernet_axiod),
    .axiid(ordered_eth_rxd),
    .axiiv(ordered_eth_crsdv && eth_crsdv),
    .axiod(),
    .axiov()
  );

endmodule

`default_nettype wire
