`default_nettype none
`timescale 1ns / 1ps

module ip_rx_tb;
  
  /* logics for inputs and outputs */
  logic clk_in;
  logic rst_in;
//  logic [1:0] axiid;
//  logic axiiv;
//  logic axiov;
  logic axiiv4;
  logic axiov4;
  logic [31:0] src_ip, dst_ip;
  logic [7:0] protocol;
  logic [15:0] packet_length;
//  logic [1:0] axiod;  /* be sure this is the right bit width! */
  logic [3:0] axiid4;
  logic [15:0] axiod4;

  internet_protocol_rx #(.N(4)) uut4
               (.clk(clk_in),
                .rst(rst_in),
                .axiid(axiid4),
                .axiiv(axiiv4),
                .axiov(axiov4),
                .src_ip_out(src_ip),
                .dst_ip_out(dst_ip),
                .protocol_out(protocol),
                .packet_length_out(packet_length));


  always begin
    #20; //25Mhz
    clk_in = !clk_in;
  end

  initial begin
    $display("Starting Sim"); //print nice message
    $dumpfile("ip_rx.vcd"); //file to store value change dump (vcd)
    $dumpvars(0,ip_rx_tb); //store everything at the current level and below
    

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

    axiid4 = 4'h4;
    #40;
    axiid4 = 4'h5;
    #40;
    axiid4 = 4'h0;
    #40;
    axiid4 = 4'h0;
    #40;
    axiid4 = 4'h0;
    #40;
    axiid4 = 4'h0;
    #40;
    axiid4 = 4'h7;
    #40;
    axiid4 = 4'h3;
    #40;

    axiid4 = 4'h0;
    #40;
    axiid4 = 4'h0;
    #40;
    axiid4 = 4'h0;
    #40;
    axiid4 = 4'h0;
    #40;
    axiid4 = 4'h4;
    #40;
    axiid4 = 4'h0;
    #40;
    axiid4 = 4'h0;
    #40;

    axiid4 = 4'h0;
    #40;
    axiid4 = 4'h4;
    #40;
    axiid4 = 4'h0;
    #40;
    axiid4 = 4'h1;
    #40;
    axiid4 = 4'h1;
    #40;

    axiid4 = 4'hb;
    #40;
    axiid4 = 4'h8;
    #40;
    axiid4 = 4'h6;
    #40;
    axiid4 = 4'h1;
    #40;

    axiid4 = 4'hc;
    #40;
    axiid4 = 4'h0;
    #40;
    axiid4 = 4'ha;
    #40;
    
    axiid4 = 4'h8;
    #40;
    axiid4 = 4'h0;
    #40;
    axiid4 = 4'h0;
    #40;
    axiid4 = 4'h0;
    #40;
    axiid4 = 4'h1;
    #40;

    axiid4 = 4'hc;
    #40;
    axiid4 = 4'h0;
    #40;
    axiid4 = 4'ha;
    #40;
    axiid4 = 4'h8;
    #40;

    axiid4 = 4'h0;
    #40;
    axiid4 = 4'h0;
    #40;
    axiid4 = 4'hc;
    #40;
    axiid4 = 4'h7;
    #40;
    
    $display("Expected source IP: 0xC0A80001, expected destination IP: 0xC0A800C7, expected length: 115, expected protocol: 0x11, actual src: %h, actual dst: %h, actual length: %d, actual protocol: %h, axiov: %d", src_ip, dst_ip, packet_length, protocol, axiov4);

    #120;
    $display("Expected source IP: 0xC0A80001, expected destination IP: 0xC0A800C7, expected length: 115, expected protocol: 0x11, actual src: %h, actual dst: %h, actual length: %d, actual protocol: %h, axiov: %d", src_ip, dst_ip, packet_length, protocol, axiov4);
    #40;
    $finish;
  end

endmodule
`default_nettype wire 
