`default_nettype none
`timescale 1ns / 1ps

module ip_tx_tb;
  
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
  logic [15:0] packet_length;
  logic [7:0] protocol;
  logic [15:0] protocol_length;
//  logic [1:0] axiod;  /* be sure this is the right bit width! */
  logic [3:0] axiod4;
  logic axi_last;

  internet_protocol_tx #(.N(4)) uut (
    .clk(clk_in),
    .rst(rst_in),
    .axiiv(axiiv4),
    .data_length_in(packet_length),
    .protocol_in(protocol),
    .transport_header_length_in(protocol_length),
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
    $dumpfile("ip_tx.vcd"); //file to store value change dump (vcd)
    $dumpvars(0,ip_tx_tb); //store everything at the current level and below
    

    $display("=========Simulating correct IP=========");

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

    protocol = 8'h11;
    protocol_length = 16'd8;
    
    $display("Expected axiov: 0, expected axiod: anything, expected axi_last: 0, actual axiov: %b, actual axiod: %b, actual axi_last: %b", axiov4, axiod4, axi_last);
    #40;
    $display("Showing Version, IHL, DSCP, and ECN");
    $display("Expected axiov: 1, expected axiod: 0x4, expected axi_last: 0, actual axiov: %b, actual axiod: %h, actual axi_last: %b", axiov4, axiod4, axi_last);
    #40;
    $display("Expected axiov: 1, expected axiod: 0x5, expected axi_last: 0, actual axiov: %b, actual axiod: %h, actual axi_last: %b", axiov4, axiod4, axi_last);
    #40;
    $display("Expected axiov: 1, expected axiod: 0x8, expected axi_last: 0, actual axiov: %b, actual axiod: %h, actual axi_last: %b", axiov4, axiod4, axi_last);
    #40;
    $display("Expected axiov: 1, expected axiod: 0x0, expected axi_last: 0, actual axiov: %b, actual axiod: %h, actual axi_last: %b", axiov4, axiod4, axi_last);
    #40;
//Length
    $display("Showing full packet length");
    $display("Expected axiov: 1, expected axiod: 0x0, expected axi_last: 0, actual axiov: %b, actual axiod: %h, actual axi_last: %b", axiov4, axiod4, axi_last);
    #40;
    $display("Expected axiov: 1, expected axiod: 0x0, expected axi_last: 0, actual axiov: %b, actual axiod: %h, actual axi_last: %b", axiov4, axiod4, axi_last);
    #40;
    $display("Expected axiov: 1, expected axiod: 0x2, expected axi_last: 0, actual axiov: %b, actual axiod: %h, actual axi_last: %b", axiov4, axiod4, axi_last);
    #40;
    $display("Expected axiov: 1, expected axiod: 0x0, expected axi_last: 0, actual axiov: %b, actual axiod: %h, actual axi_last: %b", axiov4, axiod4, axi_last);
    #40;
//ID
    $display("Showing ID");
    $display("Expected axiov: 1, expected axiod: 0x0, expected axi_last: 0, actual axiov: %b, actual axiod: %h, actual axi_last: %b", axiov4, axiod4, axi_last);
    #40;
    $display("Expected axiov: 1, expected axiod: 0x0, expected axi_last: 0, actual axiov: %b, actual axiod: %h, actual axi_last: %b", axiov4, axiod4, axi_last);
    #40;
    $display("Expected axiov: 1, expected axiod: 0x0, expected axi_last: 0, actual axiov: %b, actual axiod: %h, actual axi_last: %b", axiov4, axiod4, axi_last);
    #40;
    $display("Expected axiov: 1, expected axiod: 0x0, expected axi_last: 0, actual axiov: %b, actual axiod: %h, actual axi_last: %b", axiov4, axiod4, axi_last);
    #40;
//FLAGS + FRAG
    $display("Showing FLAGS + FRAGMENTATION");
    $display("Expected axiov: 1, expected axiod: 0x4, expected axi_last: 0, actual axiov: %b, actual axiod: %h, actual axi_last: %b", axiov4, axiod4, axi_last);
    #40;
    $display("Expected axiov: 1, expected axiod: 0x0, expected axi_last: 0, actual axiov: %b, actual axiod: %h, actual axi_last: %b", axiov4, axiod4, axi_last);
    #40;
    $display("Expected axiov: 1, expected axiod: 0x0, expected axi_last: 0, actual axiov: %b, actual axiod: %h, actual axi_last: %b", axiov4, axiod4, axi_last);
    #40;
    $display("Expected axiov: 1, expected axiod: 0x0, expected axi_last: 0, actual axiov: %b, actual axiod: %h, actual axi_last: %b", axiov4, axiod4, axi_last);
    #40;
//TTL + PROTOCOL 
    $display("Showing TTL and protocol");
    $display("Expected axiov: 1, expected axiod: 0x4, expected axi_last: 0, actual axiov: %b, actual axiod: %h, actual axi_last: %b", axiov4, axiod4, axi_last);
    #40;
    $display("Expected axiov: 1, expected axiod: 0x0, expected axi_last: 0, actual axiov: %b, actual axiod: %h, actual axi_last: %b", axiov4, axiod4, axi_last);
    #40;
    $display("Expected axiov: 1, expected axiod: 0x1, expected axi_last: 0, actual axiov: %b, actual axiod: %h, actual axi_last: %b", axiov4, axiod4, axi_last);
    #40;
    $display("Expected axiov: 1, expected axiod: 0x1, expected axi_last: 0, actual axiov: %b, actual axiod: %h, actual axi_last: %b", axiov4, axiod4, axi_last);
    #40;

//CKSUM
    $display("Showing checksum");
    $display("Expected axiov: 1, expected axiod: 0xE, expected axi_last: 0, actual axiov: %b, actual axiod: %h, actual axi_last: %b", axiov4, axiod4, axi_last);
    #40;
    $display("Expected axiov: 1, expected axiod: 0xA, expected axi_last: 0, actual axiov: %b, actual axiod: %h, actual axi_last: %b", axiov4, axiod4, axi_last);
    #40;
    $display("Expected axiov: 1, expected axiod: 0x5, expected axi_last: 0, actual axiov: %b, actual axiod: %h, actual axi_last: %b", axiov4, axiod4, axi_last);
    #40;
    $display("Expected axiov: 1, expected axiod: 0xB, expected axi_last: 0, actual axiov: %b, actual axiod: %h, actual axi_last: %b", axiov4, axiod4, axi_last);
    #40;

//SRC IP
    $display("Showing source IP");
    $display("Expected axiov: 1, expected axiod: 0x6, expected axi_last: 0, actual axiov: %b, actual axiod: %h, actual axi_last: %b", axiov4, axiod4, axi_last);
    #40;
    $display("Expected axiov: 1, expected axiod: 0x9, expected axi_last: 0, actual axiov: %b, actual axiod: %h, actual axi_last: %b", axiov4, axiod4, axi_last);
    #40;
    $display("Expected axiov: 1, expected axiod: 0x6, expected axi_last: 0, actual axiov: %b, actual axiod: %h, actual axi_last: %b", axiov4, axiod4, axi_last);
    #40;
    $display("Expected axiov: 1, expected axiod: 0x9, expected axi_last: 0, actual axiov: %b, actual axiod: %h, actual axi_last: %b", axiov4, axiod4, axi_last);
    #40;
    $display("Expected axiov: 1, expected axiod: 0x6, expected axi_last: 0, actual axiov: %b, actual axiod: %h, actual axi_last: %b", axiov4, axiod4, axi_last);
    #40;
    $display("Expected axiov: 1, expected axiod: 0x9, expected axi_last: 0, actual axiov: %b, actual axiod: %h, actual axi_last: %b", axiov4, axiod4, axi_last);
    #40;
    $display("Expected axiov: 1, expected axiod: 0x6, expected axi_last: 0, actual axiov: %b, actual axiod: %h, actual axi_last: %b", axiov4, axiod4, axi_last);
    #40;
    $display("Expected axiov: 1, expected axiod: 0x9, expected axi_last: 0, actual axiov: %b, actual axiod: %h, actual axi_last: %b", axiov4, axiod4, axi_last);
    #40;

//DST IP
    $display("Showing destination IP");
    $display("Expected axiov: 1, expected axiod: 0x1, expected axi_last: 0, actual axiov: %b, actual axiod: %h, actual axi_last: %b", axiov4, axiod4, axi_last);
    #40;
    $display("Expected axiov: 1, expected axiod: 0x2, expected axi_last: 0, actual axiov: %b, actual axiod: %h, actual axi_last: %b", axiov4, axiod4, axi_last);
    #40;
    $display("Expected axiov: 1, expected axiod: 0x1, expected axi_last: 0, actual axiov: %b, actual axiod: %h, actual axi_last: %b", axiov4, axiod4, axi_last);
    #40;
    $display("Expected axiov: 1, expected axiod: 0x2, expected axi_last: 0, actual axiov: %b, actual axiod: %h, actual axi_last: %b", axiov4, axiod4, axi_last);
    #40;
    $display("Expected axiov: 1, expected axiod: 0x6, expected axi_last: 0, actual axiov: %b, actual axiod: %h, actual axi_last: %b", axiov4, axiod4, axi_last);
    #40;
    $display("Expected axiov: 1, expected axiod: 0xB, expected axi_last: 0, actual axiov: %b, actual axiod: %h, actual axi_last: %b", axiov4, axiod4, axi_last);
    #40;
    $display("Expected axiov: 1, expected axiod: 0x0, expected axi_last: 0, actual axiov: %b, actual axiod: %h, actual axi_last: %b", axiov4, axiod4, axi_last);
    #40;
    $display("Expected axiov: 1, expected axiod: 0xD, expected axi_last: 1, actual axiov: %b, actual axiod: %h, actual axi_last: %b", axiov4, axiod4, axi_last);
    #40;


    $display("Expected axiov: 0, expected axi_last: 0, actual axiov: %b, actual axiod: %h, actual axi_last: %b", axiov4, axiod4, axi_last);
    #40;
    $finish;
  end

endmodule
`default_nettype wire 
