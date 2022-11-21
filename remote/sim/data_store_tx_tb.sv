`default_nettype none
`timescale 1ns / 1ps

module data_store_tx_tb;
  
  /* logics for inputs and outputs */
  logic clk_in;
  logic rst_in;
//  logic [1:0] axiid;
//  logic axiiv;
//  logic axiov;
  logic axiiv4;
  logic axiov4;
//  logic [1:0] axiod;  /* be sure this is the right bit width! */
  logic [11:0] axiid4;
  logic [3:0] axiod4;
  logic read_out;
  logic [15:0] data_cksum, data_length;

  data_store_tx #(.N(4), .DATA_SIZE(12)) data_in(
    .clk(clk_in),
    .rst(rst_in),
    .axiid(axiid4),
    .axiiv(axiiv4),
    .read_request(read_out),
    .axiov(axiov4),
    .axiod(axiod4),
    .data_length(data_length),
    .data_cksum(data_cksum)
  );

  always begin
    #20; //25Mhz
    clk_in = !clk_in;
  end

  initial begin
    $display("Starting Sim"); //print nice message
    $dumpfile("data_store_tx.vcd"); //file to store value change dump (vcd)
    $dumpvars(0,data_store_tx_tb); //store everything at the current level and below
    

    $display("Starting simulation no padding");

    clk_in = 0;
    rst_in = 0;
 //   axiid = 0;
 //   axiiv = 0;
    axiid4 = 0;
    axiiv4 = 0;
    read_out = 0;

    #40;
    rst_in = 1;
    #40;
    rst_in = 0;
    #40; 

    axiiv4 = 1'b1;
    axiid4 = 12'h123;
    #40;
    axiid4 = 12'h456;
    #40;
    axiid4 = 12'h789;
    #40;
    axiid4 = 12'habc;
    #40;
    axiid4 = 12'hdef;
    #40;
    axiiv4 = 1'b0;
    #40;
    read_out = 1'b1;
    #40;
    #40;
    $display("Expected axiov: 1, expected axiod: 0x1, actual axiov: %b, actual axiod: %h", axiov4, axiod4);
    #40;
    $display("Expected axiov: 1, expected axiod: 0x2, actual axiov: %b, actual axiod: %h", axiov4, axiod4);
    #40;
    $display("Expected axiov: 1, expected axiod: 0x3, actual axiov: %b, actual axiod: %h", axiov4, axiod4);
    #40;
    $display("Expected axiov: 1, expected axiod: 0x4, actual axiov: %b, actual axiod: %h", axiov4, axiod4);
    #40;
    $display("Expected axiov: 1, expected axiod: 0x5, actual axiov: %b, actual axiod: %h", axiov4, axiod4);
    #40;
    $display("Expected axiov: 1, expected axiod: 0x6, actual axiov: %b, actual axiod: %h", axiov4, axiod4);
    #40;
    
    $display("Expected axiov: 0, actual axiov: %b, actual axiod: %h, actual cksum: %h, actual length: %h", axiov4, axiod4, data_cksum, data_length);
    #160;
    $display("Expected axiov: 0, actual axiov: %b, actual axiod: %h", axiov4, axiod4);
    $finish;
  end

endmodule
`default_nettype wire 
