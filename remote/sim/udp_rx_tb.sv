`default_nettype none
`timescale 1ns / 1ps

module udp_rx_tb;
  
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
  logic kill;

  udp_rx #(.N(4)) uut4
               (.clk(clk_in),
                .rst(rst_in),
                .axiid(axiid4),
                .axiiv(axiiv4),
                .axiov(axiov4),
                .src_ip_in(src_ip),
                .dst_ip_in(dst_ip),
                .packet_length_in(packet_length),
                .kill(kill));


  always begin
    #20; //25Mhz
    clk_in = !clk_in;
  end

  initial begin
    $display("Starting Sim"); //print nice message
    $dumpfile("udp_rx.vcd"); //file to store value change dump (vcd)
    $dumpvars(0,udp_rx_tb); //store everything at the current level and below
    

    $display("=========Simulating correct UDP=========");

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
    src_ip = 32'h01_01_01_01;
    dst_ip = 32'h01_01_01_01;
    packet_length = 16'd12;

    axiid4 = 4'h0;
    #40;
    axiid4 = 4'h0;
    #40;
    axiid4 = 4'h3;
    #40;
    axiid4 = 4'h5;
    #40;

    axiid4 = 4'h0;
    #40;
    axiid4 = 4'h2;
    #40;
    axiid4 = 4'h2;
    #40;
    axiid4 = 4'hA;
    #40;

    axiid4 = 4'h0;
    #40;
    axiid4 = 4'h0;
    #40;
    axiid4 = 4'h0;
    #40;
    axiid4 = 4'hC;
    #40;

    axiid4 = 4'h5;
    #40;
    axiid4 = 4'h9;
    #40;
    axiid4 = 4'hA;
    #40;
    axiid4 = 4'h8;
    #40;

    axiid4 = 4'h1;
    #40;
    axiid4 = 4'hE;
    #40;
    axiid4 = 4'h4;
    #40;
    axiid4 = 4'hB;
    #40;

    axiid4 = 4'h8;
    #40;
    axiid4 = 4'h1;
    #40;
    axiid4 = 4'h8;
    #40;
    axiid4 = 4'h0;
    #40;
    $display("Expected axiov: 1, expected kill: 0, actual axiov: %b, actual kill: %b", axiov4, kill);
    //wait for ethernet header to read through
    #40;
    #40;
    #40;
    #40;

    #40;
    #40;
    #40;
    #40;

    axiiv4 = 0;
    #5;
    $display("Expected axiov: 1, expected kill: 0, actual axiov: %b, actual kill: %b", axiov4, kill);
    #35;
    $display("Expected axiov: 0, expected kill: 0, actual axiov: %b, actual kill: %b", axiov4, kill);

    #40;
    $display("=========Simulating mismatched lengths=========");

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
    src_ip = 32'h01_01_01_01;
    dst_ip = 32'h01_01_01_01;
    packet_length = 16'd14;

    axiid4 = 4'h0;
    #40;
    axiid4 = 4'h0;
    #40;
    axiid4 = 4'h3;
    #40;
    axiid4 = 4'h5;
    #40;

    axiid4 = 4'h0;
    #40;
    axiid4 = 4'h2;
    #40;
    axiid4 = 4'h2;
    #40;
    axiid4 = 4'hA;
    #40;

    axiid4 = 4'h0;
    #40;
    axiid4 = 4'h0;
    #40;
    axiid4 = 4'h0;
    #40;
    axiid4 = 4'hC;
    #40;

    axiid4 = 4'h5;
    #40;
    axiid4 = 4'h9;
    #40;
    axiid4 = 4'hA;
    #40;
    axiid4 = 4'h8;
    #40;

    axiid4 = 4'h1;
    #40;
    axiid4 = 4'hE;
    #40;
    axiid4 = 4'h4;
    #40;
    axiid4 = 4'hB;
    #40;

    axiid4 = 4'h8;
    #40;
    axiid4 = 4'h1;
    #40;
    axiid4 = 4'h8;
    #40;
    axiid4 = 4'h0;
    #40;
    $display("Expected axiov: 0, expected kill: 0, actual axiov: %b, actual kill: %b", axiov4, kill);
    //wait for ethernet header to read through
    #40;
    #40;
    #40;
    #40;

    #40;
    #40;
    #40;
    #40;

    axiiv4 = 0;
    #5;
    $display("Expected axiov: 0, expected kill: 0, actual axiov: %b, actual kill: %b", axiov4, kill);
    #35;
    $display("Expected axiov: 0, expected kill: 0, actual axiov: %b, actual kill: %b", axiov4, kill);
    #40;
    $display("=========Simulating incorrect checksum=========");

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
    src_ip = 32'h01_01_01_01;
    dst_ip = 32'h01_01_01_01;
    packet_length = 16'd12;

    axiid4 = 4'h0;
    #40;
    axiid4 = 4'h0;
    #40;
    axiid4 = 4'h3;
    #40;
    axiid4 = 4'h5;
    #40;

    axiid4 = 4'h0;
    #40;
    axiid4 = 4'h2;
    #40;
    axiid4 = 4'h2;
    #40;
    axiid4 = 4'hA;
    #40;

    axiid4 = 4'h0;
    #40;
    axiid4 = 4'h0;
    #40;
    axiid4 = 4'h0;
    #40;
    axiid4 = 4'hC;
    #40;

    axiid4 = 4'h5;
    #40;
    axiid4 = 4'h9;
    #40;
    axiid4 = 4'hA;
    #40;
    axiid4 = 4'h7;
    #40;

    axiid4 = 4'h1;
    #40;
    axiid4 = 4'hE;
    #40;
    axiid4 = 4'h4;
    #40;
    axiid4 = 4'hB;
    #40;

    axiid4 = 4'h8;
    #40;
    axiid4 = 4'h1;
    #40;
    axiid4 = 4'h8;
    #40;
    axiid4 = 4'h0;
    #40;
    $display("Expected axiov: 1, expected kill: 0, actual axiov: %b, actual kill: %b", axiov4, kill);
    //wait for ethernet header to read through
    #40;
    #40;
    #40;
    #40;

    #40;
    #40;
    #40;
    #40;

    axiiv4 = 0;
    #5;
    $display("Expected axiov: 1, expected kill: 0, actual axiov: %b, actual kill: %b", axiov4, kill);
    #35;
    $display("Expected axiov: 0, expected kill: 1, actual axiov: %b, actual kill: %b", axiov4, kill);
    #40;
    $display("=========Simulating no checksum=========");

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
    src_ip = 32'h01_01_01_01;
    dst_ip = 32'h01_01_01_01;
    packet_length = 16'd12;

    axiid4 = 4'h0;
    #40;
    axiid4 = 4'h0;
    #40;
    axiid4 = 4'h3;
    #40;
    axiid4 = 4'h5;
    #40;

    axiid4 = 4'h0;
    #40;
    axiid4 = 4'h2;
    #40;
    axiid4 = 4'h2;
    #40;
    axiid4 = 4'hA;
    #40;

    axiid4 = 4'h0;
    #40;
    axiid4 = 4'h0;
    #40;
    axiid4 = 4'h0;
    #40;
    axiid4 = 4'hC;
    #40;

    axiid4 = 4'h0;
    #40;
    axiid4 = 4'h0;
    #40;
    axiid4 = 4'h0;
    #40;
    axiid4 = 4'h0;
    #40;

    axiid4 = 4'h1;
    #40;
    axiid4 = 4'hE;
    #40;
    axiid4 = 4'h4;
    #40;
    axiid4 = 4'hB;
    #40;

    axiid4 = 4'h8;
    #40;
    axiid4 = 4'h1;
    #40;
    axiid4 = 4'h8;
    #40;
    axiid4 = 4'h0;
    #40;
    $display("Expected axiov: 1, expected kill: 0, actual axiov: %b, actual kill: %b", axiov4, kill);
    //wait for ethernet header to read through
    #40;
    #40;
    #40;
    #40;

    #40;
    #40;
    #40;
    #40;

    axiiv4 = 0;
    #5;
    $display("Expected axiov: 1, expected kill: 0, actual axiov: %b, actual kill: %b", axiov4, kill);
    #35;
    $display("Expected axiov: 0, expected kill: 0, actual axiov: %b, actual kill: %b", axiov4, kill);


    $finish;
  end

endmodule
`default_nettype wire 
