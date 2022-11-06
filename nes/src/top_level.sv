`timescale 1ns / 1ps
`default_nettype none

module top_level(
  input wire clk_100mhz, //clock @ 100 mhz
  input wire btnc, //btnc (used for reset)
  output logic eth_rxck,
  output logic eth_txck, //should this be input?
  input wire [3:0] eth_rxd,
  input wire eth_rxctl,
  output wire eth_txctl,
  output wire [3:0] eth_txd,
  output logic eth_rst_b
 // output logic [15:0] led, //just here for the funs

 // output logic [7:0] an,
 // output logic ca,cb,cc,cd,ce,cf,cg

  );
  assign eth_txctl = 0;
  assign eth_txd = 0;
  parameter N = $bits(eth_rxd);
  parameter MY_MAC = 48'h37_38_38_38_38_38;

  /* have btnd control system reset */
  logic sys_rst;
  assign sys_rst = btnc;
  assign eth_rst_b = ~sys_rst;

  //TODO: make these a 25MHz clock when we move to a video board
  divider ether_clk1(
    .clk(clk_100mhz),
    .ethclk(eth_txck)
  );

  divider ether_clk2(
    .clk(clk_100mhz),
    .ethclk(eth_rxck)
  );

  network_stack #(.N(N)) (
    .clk(eth_rxck),
    .rst(sys_rst),
    .eth_rxd(eth_rxd),
    .eth_txd(eth_txd),
    .eth_crsdv(eth_rxctl),
    .eth_txen(eth_txctl),
    .mac(MY_MAC)
  );

endmodule
`default_nettype wire
