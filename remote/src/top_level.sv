`timescale 1ns / 1ps
`default_nettype none

module top_level(
  input wire clk, //clock @ 100 mhz
  input wire btnc, //btnc (used for reset)
  output logic eth_refclk,
  input wire [1:0] eth_rxd,
  output logic eth_rstn,
  input wire eth_crsdv,
  output logic [1:0] eth_txd,
  output logic eth_txen
//  output logic [15:0] led, //just here for the funs

//  output logic [7:0] an,
//  output logic ca,cb,cc,cd,ce,cf,cg

  );

  parameter MY_MAC = 48'h42_04_20_42_04_20;
  parameter N = $bits(eth_rxd);

  /* have btnd control system reset */
  logic sys_rst;
  assign sys_rst = btnc;
  assign eth_rstn = ~sys_rst;

  
  divider ether_clk( 
    .clk(clk),
    .ethclk(eth_refclk)
  );

  network_stack #(.N(N)) da_net(
    .clk(eth_refclk),
    .rst(sys_rst),
    .eth_rxd(eth_rxd),
    .eth_crsdv(eth_crsdv),
    .mac(MY_MAC),
    .eth_txd(eth_txd),
    .eth_txen(eth_txen)
  );

endmodule
`default_nettype wire
