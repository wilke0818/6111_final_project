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

  logic [13:0] count;
  logic old_done;

  logic [N-1:0] ether_axiod, bitorder_axiod, firewall_axiod;
  logic [31:0] aggregate_axiod, valid_agg;
  logic kill, done, ether_axiov, bitorder_axiov, firewall_axiov, aggregate_axiov;

  
  divider ether_clk( 
    .clk(clk),
    .ethclk(eth_refclk)
  );

  ether #(.N(N)) ethermod(
    .clk(eth_refclk),
    .rst(sys_rst),
    .rxd(eth_rxd),
    .crsdv(eth_crsdv),
    .axiov(ether_axiov),
    .axiod(ether_axiod)
  );

  bitorder #(.N(N)) bitmod(
    .clk(eth_refclk),
    .rst(sys_rst),
    .axiid(ether_axiod),
    .axiiv(ether_axiov),
    .axiod(bitorder_axiod),
    .axiov(bitorder_axiov));

  firewall #(.N(N)) firewallmod(
    .clk(eth_refclk),
    .rst(sys_rst),
    .axiid(bitorder_axiod),
    .axiiv(bitorder_axiov),
    .axiod(firewall_axiod),
    .axiov(firewall_axiov));

  cksum cksummod(
    .clk(eth_refclk),
    .rst(sys_rst),
    .axiid(ether_axiod),
    .axiiv(ether_axiov),
    .done(done),
    .kill(kill));

//  aggregate agger(
//    .clk(eth_refclk),
//    .rst(sys_rst),
//    .axiid(firewall_axiod),
//    .axiiv(firewall_axiov),
//    .axiov(aggregate_axiov),
//    .axiod(aggregate_axiod)
//  );

//  assign led[13:0] = count;
//  assign led[14] = done;
//  assign led[15] = kill;

  

//  always_comb begin
//    if (aggregate_axiov) begin
//      valid_agg = aggregate_axiod;
//    end else if (firewall_axiov) begin
//      valid_agg = 0;
//    end
//  end

  always_ff @(posedge eth_refclk) begin
    if (~old_done && done && firewall_axiov && ~kill) begin
      count <= count + 1;
    end
    old_done <= done;
  end

endmodule
`default_nettype wire
