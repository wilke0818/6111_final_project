`timescale 1ns / 1ps
`default_nettype none


module ethernet_rx #(parameter N=2) (
  input wire clk, //clock @ 25 or 50 mhz
  input wire rst, //btnc (used for reset)
  input wire [N-1:0] axiid,
  input wire axiiv,
  input wire [47:0] mac,
  output logic axiov, //use valid for IP
  output logic ethertype, //output ethertype
  output logic rx_done,
  output logic rx_kill
  );

  logic [N-1:0] ether_axiod, bitorder_axiod, firewall_axiod;
  logic kill, done, ether_axiov, bitorder_axiov, firewall_axiov, aggregate_axiov;

  ether #(.N(N)) ethermod(
    .clk(clk),
    .rst(rst),
    .rxd(axiid),
    .crsdv(axiiv),
    .axiov(ether_axiov),
    .axiod(ether_axiod)
  );

  bitorder #(.N(N)) bitmod(
    .clk(clk),
    .rst(rst),
    .axiid(ether_axiod),
    .axiiv(ether_axiov),
    .axiod(bitorder_axiod),
    .axiov(bitorder_axiov));

  firewall #(.N(N)) firewallmod(
    .clk(clk),
    .rst(rst),
    .axiid(bitorder_axiod),
    .axiiv(bitorder_axiov),
    .my_mac(mac),
    .axiod(firewall_axiod),
    .axiov(firewall_axiov));

  ethertype #(.N(N)) ethertypemod(
    .clk(clk),
    .rst(rst),
    .axiid(firewall_axiod),
    .axiiv(firewall_axiov),
    .axiov(axiov),
    .axiod(ethertype)
  );

  cksum4bit cksummod(
    .clk(clk),
    .rst(rst),
    .axiid(ether_axiod),
    .axiiv(ether_axiov),
    .done(done),
    .kill(kill));

  assign rx_kill = kill;
  assign rx_done = done;

endmodule
`default_nettype wire
