`default_nettype none
`timescale 1ns / 1ps

module udp_tx_tb;
  
  /* logics for inputs and outputs */
  logic clk_in;
  logic rst_in;
//  logic [1:0] axiid;
//  logic axiiv;
//  logic axiov;
  logic axiiv4;
  logic axiov4;
  logic [31:0] src_ip, dst_ip;
  logic [15:0] data_cksum;
  logic [15:0] packet_length, src_port, dst_port;
//  logic [1:0] axiod;  /* be sure this is the right bit width! */
  logic [3:0] axiod4;
  logic axi_last;

  udp_tx #(.N(4)) uut (
    .clk(clk_in),
    .rst(rst_in),
    .axiiv(axiiv4),
    .src_port_in(src_port),
    .dst_port_in(dst_port),
    .data_length_in(packet_length),
    .data_checksum_in(data_cksum),
    .src_ip_in(src_ip),
    .dst_ip_in(dst_ip),
    .axiov(axiov4),
    .axiod(axiod4),
    .axi_last(axi_last)
  );

  always begin
    #20; //25Mhz
    clk_in = !clk_in;
  end

  initial begin
    $display("Starting Sim"); //print nice message
    $dumpfile("udp_tx.vcd"); //file to store value change dump (vcd)
    $dumpvars(0,udp_tx_tb); //store everything at the current level and below
    

    $display("=========Simulating correct UDP=========");

    clk_in = 0;
    rst_in = 0;
 //   axiid = 0;
 //   axiiv = 0;
    axiiv4 = 0;
    #40;
    rst_in = 1;
    #40;
    rst_in = 0;
    #40; 
    axiiv4 = 1'b1;
    src_ip = 32'h69_69_69_69;
    dst_ip = 32'h12_12_6B_0D;
    packet_length = 16'd4;

    src_port = 16'd53;
    dst_port = 16'd554;
    data_cksum = 16'h9fcb;
    $display("Expected axiov: 0, expected axiod: anything, expected axi_last: 0, actual axiov: %b, actual axiod: %b, actual axi_last: %b", axiov4, axiod4, axi_last);
    #40;
    $display("Expected axiov: 1, expected axiod: 0x0, expected axi_last: 0, actual axiov: %b, actual axiod: %h, actual axi_last: %b", axiov4, axiod4, axi_last);
    #40;
    $display("Expected axiov: 1, expected axiod: 0x0, expected axi_last: 0, actual axiov: %b, actual axiod: %h, actual axi_last: %b", axiov4, axiod4, axi_last);
    #40;
    $display("Expected axiov: 1, expected axiod: 0x3, expected axi_last: 0, actual axiov: %b, actual axiod: %h, actual axi_last: %b", axiov4, axiod4, axi_last);
    #40;
    $display("Expected axiov: 1, expected axiod: 0x5, expected axi_last: 0, actual axiov: %b, actual axiod: %h, actual axi_last: %b", axiov4, axiod4, axi_last);
    #40;
//DST PORT
    $display("Expected axiov: 1, expected axiod: 0x0, expected axi_last: 0, actual axiov: %b, actual axiod: %h, actual axi_last: %b", axiov4, axiod4, axi_last);
    #40;
    $display("Expected axiov: 1, expected axiod: 0x2, expected axi_last: 0, actual axiov: %b, actual axiod: %h, actual axi_last: %b", axiov4, axiod4, axi_last);
    #40;
    $display("Expected axiov: 1, expected axiod: 0x2, expected axi_last: 0, actual axiov: %b, actual axiod: %h, actual axi_last: %b", axiov4, axiod4, axi_last);
    #40;
    $display("Expected axiov: 1, expected axiod: 0xA, expected axi_last: 0, actual axiov: %b, actual axiod: %h, actual axi_last: %b", axiov4, axiod4, axi_last);
    #40;
//LENGTH
    $display("Expected axiov: 1, expected axiod: 0x0, expected axi_last: 0, actual axiov: %b, actual axiod: %h, actual axi_last: %b", axiov4, axiod4, axi_last);
    #40;
    $display("Expected axiov: 1, expected axiod: 0x0, expected axi_last: 0, actual axiov: %b, actual axiod: %h, actual axi_last: %b", axiov4, axiod4, axi_last);
    #40;
    $display("Expected axiov: 1, expected axiod: 0x0, expected axi_last: 0, actual axiov: %b, actual axiod: %h, actual axi_last: %b", axiov4, axiod4, axi_last);
    #40;
    $display("Expected axiov: 1, expected axiod: 0xC, expected axi_last: 0, actual axiov: %b, actual axiod: %h, actual axi_last: %b", axiov4, axiod4, axi_last);
    #40;
//CKSUM
    $display("Expected axiov: 1, expected axiod: 0x0, expected axi_last: 0, actual axiov: %b, actual axiod: %h, actual axi_last: %b", axiov4, axiod4, axi_last);
    #40;
    $display("Expected axiov: 1, expected axiod: 0xD, expected axi_last: 0, actual axiov: %b, actual axiod: %h, actual axi_last: %b", axiov4, axiod4, axi_last);
    #40;
    $display("Expected axiov: 1, expected axiod: 0xB, expected axi_last: 0, actual axiov: %b, actual axiod: %h, actual axi_last: %b", axiov4, axiod4, axi_last);
    #40;
    $display("Expected axiov: 1, expected axiod: 0xA, expected axi_last: 1, actual axiov: %b, actual axiod: %h, actual axi_last: %b", axiov4, axiod4, axi_last);
    #40;
    $display("Expected axiov: 0, expected axi_last: 0, actual axiov: %b, actual axiod: %h, actual axi_last: %b", axiov4, axiod4, axi_last);
    #40;
    $finish;
  end

endmodule
`default_nettype wire 
