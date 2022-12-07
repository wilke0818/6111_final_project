`default_nettype none
`timescale 1ns / 1ps

`define ETHERNET          176'h55_55_55_55_55_55_55_5D_FF_FF_FF_FF_FF_FF_96_96_96_96_96_96_8000
`define IP                160'h54_08_00_02_00_00_04_00_04_11_AE_B5_21_21_B6_D0_96_96_96_96
`define UDP               64'h00_53_20_A2_00_C0_D4_15
`define DATA              32'hE1_B4_18_08
`define ETH_CKSUM         32'h6793D750


module network_stack_tx_tb;
  
  /* logics for inputs and outputs */
  logic clk_in;
  logic rst_in;
//  logic [1:0] axiid;
//  logic axiiv;
//  logic axiov;
  logic axiiv4;
  logic axiov4;
  logic [31:0] src_ip, dst_ip;
//  logic [7:0] protocol;
  logic [15:0] packet_length;
//  logic [1:0] axiod;  /* be sure this is the right bit width! */
  logic [15:0] axiid4;
  logic [N-1:0] axiod4;

  parameter N = 2;

	/* constants */
  logic [0:175] ethernet;
  logic [0:159] ip;
  logic [0:63] udp;
  logic [0:31] data;
  logic [0:31] eth_cksum;

  assign ethernet = `ETHERNET;
  assign ip = `IP;
  assign udp = `UDP;
  assign data = `DATA;
  assign eth_cksum = `ETH_CKSUM;

  network_stack #(.N(N), .DATA_SIZE(16)) uut4
               (.clk(clk_in),
                .rst(rst_in),
                .axiiv(axiiv4),
                .axiid(axiid4),
                .mac(48'h69_69_69_69_69_69),
                .dst_mac(48'hFF_FF_FF_FF_FF_FF),
                .eth_txen(axiov4),
                .eth_txd(axiod4),
                .dst_ip_in(32'h69_69_69_69),
                .transport_protocol_in(8'h11),
                .ethertype_in(16'h0800),
                .udp_src_port_in(16'd53),
                .udp_dst_port_in(16'd554));


  always begin
    #20; //25Mhz
    clk_in = !clk_in;
  end

  initial begin
    $display("Starting Sim"); //print nice message
    $dumpfile("network_stack_tx.vcd"); //file to store value change dump (vcd)
    $dumpvars(0,network_stack_tx_tb); //store everything at the current level and below
    

    clk_in = 0;
    rst_in = 0;
 //   axiid = 0;
 //   axiiv = 0;
    axiid4 = 0;
    axiiv4 = 0;
    #40;
    rst_in = 1;
    #40;
    rst_in = 0;
    #40; 
    axiiv4 = 1'b1;
    axiid4 = 16'h1E_4B;
    #40;
    axiid4 = 16'h81_80;
    #40;
    axiiv4 = 0;
    #40;
    $display("expected eth_txen: 0, eth_txd: X, actual eth_txen: %b, eth_txd: %b", axiov4, axiod4);
    #40;
    $display("expected eth_txen: 0, eth_txd: X, actual eth_txen: %b, eth_txd: %b", axiov4, axiod4);
    #40;
    $display("expected eth_txen: 0, eth_txd: X, actual eth_txen: %b, eth_txd: %b", axiov4, axiod4);
    #40;
    $display("expected eth_txen: 0, eth_txd: X, actual eth_txen: %b, eth_txd: %b", axiov4, axiod4);
    #40;    
    //ETHERNET 
    for (int i = 0; i < 176; i= i+4) begin
      $display("expected eth_txen: 1, eth_txd: %b, actual eth_txen: %b, eth_txd: %b", {ethernet[i+2], ethernet[i+3]}, axiov4, axiod4);
      #40;
      $display("expected eth_txen: 1, eth_txd: %b, actual eth_txen: %b, eth_txd: %b", {ethernet[i], ethernet[i+1]}, axiov4, axiod4);
      #40;
    end
    $display("Starting to show IP");
    
    //IP
    for (int i = 0; i < 160; i= i+4) begin
      $display("expected eth_txen: 1, eth_txd: %b, actual eth_txen: %b, eth_txd: %b", {ip[i+2], ip[i+3]}, axiov4, axiod4);
      #40;
      $display("expected eth_txen: 1, eth_txd: %b, actual eth_txen: %b, eth_txd: %b", {ip[i], ip[i+1]}, axiov4, axiod4);
      #40;
    end
    $display("Starting to show UDP");
    
    //UDP
    for (int i = 0; i < 64; i= i+4) begin
      $display("expected eth_txen: 1, eth_txd: %b, actual eth_txen: %b, eth_txd: %b", {udp[i+2], udp[i+3]}, axiov4, axiod4);
      #40;
      $display("expected eth_txen: 1, eth_txd: %b, actual eth_txen: %b, eth_txd: %b", {udp[i], udp[i+1]}, axiov4, axiod4);
      #40;
    end
    $display("Starting to show DATA");
    
    //DATA
    for (int i = 0; i < 32; i= i+4) begin
      $display("expected eth_txen: 1, eth_txd: %b, actual eth_txen: %b, eth_txd: %b", {data[i+2], data[i+3]}, axiov4, axiod4);
      #40;
      $display("expected eth_txen: 1, eth_txd: %b, actual eth_txen: %b, eth_txd: %b", {data[i], data[i+1]}, axiov4, axiod4);
      #40;
    end
    $display("Starting to show CKSUM");
    
    //CKSUM
    for (int i = 0; i < 32; i= i+4) begin
      $display("expected eth_txen: 1, eth_txd: %b, actual eth_txen: %b, eth_txd: %b", {eth_cksum[i], eth_cksum[i+1]}, axiov4, axiod4);
      #40;
      $display("expected eth_txen: 1, eth_txd: %b, actual eth_txen: %b, eth_txd: %b", {eth_cksum[i+2], eth_cksum[i+3]}, axiov4, axiod4);
      #40;
    end

    for (int i = 0; i < 96/2; i=i+1) begin
      #40;
    end
    #120;
    $finish;
  end

endmodule
`default_nettype wire 
