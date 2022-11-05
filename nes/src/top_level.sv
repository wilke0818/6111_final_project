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

  logic [13:0] count;
  logic old_done;

  logic [N-1:0] ether_axiod, bitorder_axiod, firewall_axiod;
  logic [31:0] aggregate_axiod, valid_agg;
  logic kill, done, ether_axiov, bitorder_axiov, firewall_axiov, aggregate_axiov;

  //TODO: make these a 25MHz clock when we move to a video board
  divider ether_clk1(
    .clk(clk_100mhz),
    .ethclk(eth_txck)
  );

  divider ether_clk2(
    .clk(clk_100mhz),
    .ethclk(eth_rxck)
  );

  ether #(.N(N)) ethermod(
    .clk(eth_rxck),
    .rst(sys_rst),
    .rxd(eth_rxd),
    .crsdv(eth_rxctl),
    .axiov(ether_axiov),
    .axiod(ether_axiod)
  );

  bitorder #(.N(N)) bitmod(
    .clk(eth_rxck),
    .rst(sys_rst),
    .axiid(ether_axiod),
    .axiiv(ether_axiov),
    .axiod(bitorder_axiod),
    .axiov(bitorder_axiov));

  firewall #(.N(N)) firewallmod(
    .clk(eth_rxck),
    .rst(sys_rst),
    .axiid(bitorder_axiod),
    .axiiv(bitorder_axiov),
    .my_mac(MY_MAC),
    .axiod(firewall_axiod),
    .axiov(firewall_axiov));

  cksum cksummod(
    .clk(eth_rxck),
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

  always_ff @(posedge eth_rxck) begin
    if (~old_done && done && firewall_axiov && ~kill) begin
      count <= count + 1;
    end
    old_done <= done;
  end

endmodule
`default_nettype wire
