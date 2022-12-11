`default_nettype none
`timescale 1ns / 1ps

`define PREAMBLE          64'h55_55_55_55_55_55_55_5D
`define MAC_BCAST         48'hFF_FF_FF_FF_FF_FF
`define MAC_SRC           48'h96_96_96_96_96_96
`define ETYPE             16'h0080
`define VERSION_HLENGTH   8'b01010100
`define DSCP_ECN          8'b00001000
`define LENGTH            16'b00000000_00000010              //20 for IP + 12 for UDP and data
`define ID                16'h0000
`define FRAGMENT          16'b0000010000000000
`define TTL               8'b00000100
`define PROTOCOL          8'b00010001
`define IP_CKSUM          16'h51_42
`define IP_SRC            32'h96_96_96_96
`define IP_DST            32'h21_21_b6_d0
`define SRC_PORT          16'h00_53
`define DST_PORT          16'h20_A2
`define UDP_LENGTH        16'h00_C0
`define UDP_CKSUM         16'h95_8A
`define DATA              32'hE1_B4_18_08
`define ETH_CKSUM         32'hF47AFBB1

module network_stack_rx_tb;
  
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
  logic [3:0] axiid;
  logic [15:0] axiod4;

	/* constants */
  logic[0:63] preamble;
  logic[0:47] dst, src;
  logic[0:15] etype;
  logic[0:7] version_hlength;
  logic[0:7] dscp_ecn;
  logic[0:15] length;
  logic[0:15] id;
  logic[0:15] fragment;
  logic[0:7] ttl;
  logic[0:7] protocol;
  logic[0:15] ip_cksum;
  logic[0:31] ip_src;
  logic[0:31] ip_dst;
  logic[0:15] src_port;
  logic[0:15] dst_port;
  logic[0:15] udp_length;
  logic[0:15] udp_cksum;
  logic[0:31] data;
  logic[0:31] eth_cksum;

  assign preamble = `PREAMBLE;
  assign dst = `MAC_BCAST;
  assign src = `MAC_SRC;
  assign etype = `ETYPE;
  assign version_hlength = `VERSION_HLENGTH;
  assign dscp_ecn = `DSCP_ECN;
  assign length = `LENGTH;
  assign id = `ID;
  assign fragment = `FRAGMENT;
  assign ttl = `TTL;
  assign protocol = `PROTOCOL;
  assign ip_cksum = `IP_CKSUM;
  assign ip_src = `IP_SRC;
  assign ip_dst = `IP_DST;
  assign src_port = `SRC_PORT;
  assign dst_port = `DST_PORT;
  assign udp_length = `UDP_LENGTH;
  assign udp_cksum = `UDP_CKSUM;
  assign data = `DATA;
  assign eth_cksum = `ETH_CKSUM;

  network_stack_rx #(.N(4)) uut4
               (.clk(clk_in),
                .rst(rst_in),
                .eth_rxd(axiid),
                .eth_crsdv(axiiv4),
                .mac(48'h42_04_20_42_04_20),
                .axiov(axiov4),
                .axiod(axiod4));


  always begin
    #20; //25Mhz
    clk_in = !clk_in;
  end

  initial begin
    $display("Starting Sim"); //print nice message
    $dumpfile("network_stack_rx.vcd"); //file to store value change dump (vcd)
    $dumpvars(0,network_stack_rx_tb); //store everything at the current level and below
    

    clk_in = 0;
    rst_in = 0;
 //   axiid = 0;
 //   axiiv = 0;
    axiid = 0;
    axiiv4 = 0;
    #40;
    rst_in = 1;
    #40;
    rst_in = 0;
    #40; 

    axiiv4 = 1'b1;
    
    //PREAMBLE
    for (int i = 0; i < 64; i=i+4) begin
      axiid = {preamble[i], preamble[i+1], preamble[i+2], preamble[i+3]};
      #40;
    end

    //ETH DST
    for (int i = 0; i < 48; i=i+4) begin
      axiid = {dst[i], dst[i+1], dst[i+2], dst[i+3]};
      #40;
    end

    //ETH SRC
    for (int i = 0; i < 48; i=i+4) begin
      axiid = {src[i], src[i+1], src[i+2], src[i+3]};
      #40;
    end

    //ETYPE
    for (int i = 0; i < 16; i=i+4) begin
      axiid = {etype[i], etype[i+1], etype[i+2], etype[i+3]};
      #40;
    end

    //VERSION_HLENGTH
    for (int i = 0; i < 8; i=i+4) begin
      axiid = {version_hlength[i], version_hlength[i+1], version_hlength[i+2], version_hlength[i+3]};
      #40;
    end

    //DSCP_ECN
    for (int i = 0; i < 8; i=i+4) begin
      axiid = {dscp_ecn[i], dscp_ecn[i+1], dscp_ecn[i+2], dscp_ecn[i+3]};
      #40;
    end

    //LENGTH
    for (int i = 0; i < 16; i=i+4) begin
      axiid = {length[i], length[i+1], length[i+2], length[i+3]};
      #40;
    end

    //ID
    for (int i = 0; i < 16; i=i+4) begin
      axiid = {id[i], id[i+1], id[i+2], id[i+3]};
      #40;
    end

    //FRAGMENTS
    for (int i = 0; i < 16; i=i+4) begin
      axiid = {fragment[i], fragment[i+1], fragment[i+2], fragment[i+3]};
      #40;
    end

    //TTL
    for (int i = 0; i < 8; i=i+4) begin
      axiid = {ttl[i], ttl[i+1], ttl[i+2], ttl[i+3]};
      #40;
    end

    //PROTOCOL
    for (int i = 0; i < 8; i=i+4) begin
      axiid = {protocol[i], protocol[i+1], protocol[i+2], protocol[i+3]};
      #40;
    end

    //IP_CKSUM
    for (int i = 0; i < 16; i=i+4) begin
      axiid = {ip_cksum[i], ip_cksum[i+1], ip_cksum[i+2], ip_cksum[i+3]};
      #40;
    end

    //IP_SRC
    for (int i = 0; i < 32; i=i+4) begin
      axiid = {ip_src[i], ip_src[i+1], ip_src[i+2], ip_src[i+3]};
      #40;
    end

    //IP_DST
    for (int i = 0; i < 32; i=i+4) begin
      axiid = {ip_dst[i], ip_dst[i+1], ip_dst[i+2], ip_dst[i+3]};
      #40;
    end

    //SRC_PORT
    for (int i = 0; i < 16; i=i+4) begin
      axiid = {src_port[i], src_port[i+1], src_port[i+2], src_port[i+3]};
      #40;
    end

    //DST_PORT
    for (int i = 0; i < 16; i=i+4) begin
      axiid = {dst_port[i], dst_port[i+1], dst_port[i+2], dst_port[i+3]};
      #40;
    end

    //UDP_LENGTH
    for (int i = 0; i < 16; i=i+4) begin
      axiid = {udp_length[i], udp_length[i+1], udp_length[i+2], udp_length[i+3]};
      #40;
    end

    //UDP_CKSUM
    for (int i = 0; i < 16; i=i+4) begin
      axiid = {udp_cksum[i], udp_cksum[i+1], udp_cksum[i+2], udp_cksum[i+3]};
      #40;
    end

    //DATA
    for (int i = 0; i < 32; i=i+4) begin
      axiid = {data[i], data[i+1], data[i+2], data[i+3]};
      #40;
    end

    //ETH_CKSUM
    for (int i = 0; i < 32; i=i+4) begin
      axiid = {eth_cksum[i], eth_cksum[i+1], eth_cksum[i+2], eth_cksum[i+3]};
      #40;
    end
    axiiv4 = 0;

    $display("axiov: %b, axiod: %h", axiov4, axiov4);
    #40;
    $display("axiov: %b, axiod: %h", axiov4, axiov4);
    #40;
    $display("axiov: %b, axiod: %h", axiov4, axiov4);
    #40;
    $display("axiov: %b, axiod: %h", axiov4, axiov4);
    #40;

    #400;

    axiiv4 = 1'b1;
    
    //PREAMBLE
    for (int i = 0; i < 64; i=i+4) begin
      axiid = {preamble[i], preamble[i+1], preamble[i+2], preamble[i+3]};
      #40;
    end

    //ETH DST
    for (int i = 0; i < 48; i=i+4) begin
      axiid = {dst[i], dst[i+1], dst[i+2], dst[i+3]};
      #40;
    end

    //ETH SRC
    for (int i = 0; i < 48; i=i+4) begin
      axiid = {src[i], src[i+1], src[i+2], src[i+3]};
      #40;
    end

    //ETYPE
    for (int i = 0; i < 16; i=i+4) begin
      axiid = {etype[i], etype[i+1], etype[i+2], etype[i+3]};
      #40;
    end

    //VERSION_HLENGTH
    for (int i = 0; i < 8; i=i+4) begin
      axiid = {version_hlength[i], version_hlength[i+1], version_hlength[i+2], version_hlength[i+3]};
      #40;
    end

    //DSCP_ECN
    for (int i = 0; i < 8; i=i+4) begin
      axiid = {dscp_ecn[i], dscp_ecn[i+1], dscp_ecn[i+2], dscp_ecn[i+3]};
      #40;
    end

    //LENGTH
    for (int i = 0; i < 16; i=i+4) begin
      axiid = {length[i], length[i+1], length[i+2], length[i+3]};
      #40;
    end

    //ID
    for (int i = 0; i < 16; i=i+4) begin
      axiid = {id[i], id[i+1], id[i+2], id[i+3]};
      #40;
    end

    //FRAGMENTS
    for (int i = 0; i < 16; i=i+4) begin
      axiid = {fragment[i], fragment[i+1], fragment[i+2], fragment[i+3]};
      #40;
    end

    //TTL
    for (int i = 0; i < 8; i=i+4) begin
      axiid = {ttl[i], ttl[i+1], ttl[i+2], ttl[i+3]};
      #40;
    end

    //PROTOCOL
    for (int i = 0; i < 8; i=i+4) begin
      axiid = {protocol[i], protocol[i+1], protocol[i+2], protocol[i+3]};
      #40;
    end

    //IP_CKSUM
    for (int i = 0; i < 16; i=i+4) begin
      axiid = {ip_cksum[i], ip_cksum[i+1], ip_cksum[i+2], ip_cksum[i+3]};
      #40;
    end

    //IP_SRC
    for (int i = 0; i < 32; i=i+4) begin
      axiid = {ip_src[i], ip_src[i+1], ip_src[i+2], ip_src[i+3]};
      #40;
    end

    //IP_DST
    for (int i = 0; i < 32; i=i+4) begin
      axiid = {ip_dst[i], ip_dst[i+1], ip_dst[i+2], ip_dst[i+3]};
      #40;
    end

    //SRC_PORT
    for (int i = 0; i < 16; i=i+4) begin
      axiid = {src_port[i], src_port[i+1], src_port[i+2], src_port[i+3]};
      #40;
    end

    //DST_PORT
    for (int i = 0; i < 16; i=i+4) begin
      axiid = {dst_port[i], dst_port[i+1], dst_port[i+2], dst_port[i+3]};
      #40;
    end

    //UDP_LENGTH
    for (int i = 0; i < 16; i=i+4) begin
      axiid = {udp_length[i], udp_length[i+1], udp_length[i+2], udp_length[i+3]};
      #40;
    end

    //UDP_CKSUM
    for (int i = 0; i < 16; i=i+4) begin
      axiid = {udp_cksum[i], udp_cksum[i+1], udp_cksum[i+2], udp_cksum[i+3]};
      #40;
    end

    //DATA
    for (int i = 0; i < 32; i=i+4) begin
      axiid = {data[i], data[i+1], data[i+2], data[i+3]};
      #40;
    end

    //ETH_CKSUM
    for (int i = 0; i < 32; i=i+4) begin
      axiid = {eth_cksum[i], eth_cksum[i+1], eth_cksum[i+2], eth_cksum[i+3]};
      #40;
    end


    $display("axiov: %b, axiod: %h", axiov4, axiov4);
    #40;
    $display("axiov: %b, axiod: %h", axiov4, axiov4);
    #40;
    $display("axiov: %b, axiod: %h", axiov4, axiov4);
    #40;
    $display("axiov: %b, axiod: %h", axiov4, axiov4);
    #40;


    $finish;
  end

endmodule
`default_nettype wire 
