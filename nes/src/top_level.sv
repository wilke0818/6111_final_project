`timescale 1ns / 1ps
`default_nettype none

module top_level(
/******** 4 bit *************
  input wire clk_100mhz, //clock @ 100 mhz
  input wire btnc, //btnc (used for reset)
  input wire btnr,
  input wire eth_rxck,
  output logic eth_txck, //should this be input?
  input wire [1:0] eth_rxd,
  input wire eth_rxctl,
  output wire eth_txctl,
  output wire [1:0] eth_txd,
  output logic eth_rst_b
 // output logic [15:0] led, //just here for the funs

 // output logic [7:0] an,
 // output logic ca,cb,cc,cd,ce,cf,cg
 
 *******************************/
 
      input wire clk
	, input wire btnc
	, input wire btnr
	, output logic [1:0] led
	, input wire eth_crsdv
	, input wire [1:0] eth_rxd
	, output logic eth_txen
	, output logic [1:0] eth_txd
	, output logic eth_rstn
	, output logic eth_refclk

  );
  
  assign led[2] = eth_crsdv;
  assign led[1:0] = eth_rxd;
  
  // assign eth_txctl = 0;
  // assign eth_txd = 0;
  parameter N = $bits(eth_txd);
  parameter MY_MAC = 48'h12_34_56_78_90_AB;
  parameter DEST_MAC = 48'hFF_FF_FF_FF_FF_FF;

  /* have btnd control system reset */
  logic sys_rst;
  assign sys_rst = btnc;
  // assign eth_rst_b = ~sys_rst;
  assign eth_rstn = ~sys_rst;


  logic l;
  logic l2;

/*
  ila il
      ( .clk(eth_txck)
      , .probe0(eth_txctl)
      , .probe1(eth_txd)
      );
*/
  //TODO: make these a 25MHz clock when we move to a video board
  clk_wiz_0 ether_clk1(
    .clk_in1(clk),
    .clk_out1(eth_refclk)
  );
/*
  network_stack #(.N(N)) network_m (
    .clk(eth_rxck),
    .rst(sys_rst),
    .eth_rxd(eth_rxd),
    .eth_txd(eth_txd),
    .eth_crsdv(eth_rxctl),
    .eth_txen(eth_txctl),
    .mac(MY_MAC)
  );
  */
  // ETHERNET TEST
  ethernet_tx #(.N(N)) ethernet_tx_m(
  .clk(eth_refclk),             // clock @ 25 or 50 mhz
  .rst(sys_rst),             // btnc (used for reset)
  .axiid(0),   // AXI Input Data
  .axiiv(btnr),           // AXI Input Valid
  .my_mac(MY_MAC),   // MAC address of this FPGA
  .dest_mac(DEST_MAC), // MAC address of destination device
  .etype(16'h0800),    // Ethernet type
  .axiov(eth_txen),         // Transmitting valid data
  .axiod(eth_txd) // Data being transmitted
  );

endmodule
`default_nettype wire
