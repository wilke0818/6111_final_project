`default_nettype none
`timescale 1ns / 1ps

module data_store_rx_tb;
  
  /* logics for inputs and outputs */
  logic clk_in;
  logic rst_in;
//  logic [1:0] axiid;
//  logic axiiv;
//  logic axiov;
  logic axiiv4;
  logic axiov4;
//  logic [1:0] axiod;  /* be sure this is the right bit width! */
  logic [3:0] axiid4;
  logic [15:0] axiod4;
  logic read_out;
  logic [15:0] large_data;

  data_store_rx #(.N(4)) data_in(
    .clk(clk_in),
    .rst(rst_in),
    .axiid(axiid4),
    .axiiv(axiiv4),
    .read_request(read_out),
    .axiov(axiov4),
    .axiod(axiod4)
  );

  always begin
    #20; //25Mhz
    clk_in = !clk_in;
  end

  initial begin
    $display("Starting Sim"); //print nice message
    $dumpfile("data_store_rx.vcd"); //file to store value change dump (vcd)
    $dumpvars(0,data_store_rx_tb); //store everything at the current level and below
    

    $display("Starting simulation");

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

    for (int i = 0; i < 200; i=i+1) begin
      large_data = i;
      axiid4 = large_data[15:12];
      #40;
      axiid4 = large_data[11:8];
      #40;
      axiid4 = large_data[7:4];
      #40;
      axiid4 = large_data[3:0];
      #40;
    end
    
    $display("Expected axiov: 0, expected axiod: 0, actual axiov: %b, actual axiod: %h", axiov4, axiod4);
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
    $display("Expected axiov: 0, expected axiod: 0, actual axiov: %b, actual axiod: %h", axiov4, axiod4);
    #35;
    read_out = 1;
    #40;
    #40;
    $display("Expected axiov: 1, expected axiod: 0x1e4b, actual axiov: %b, actual axiod: %h", axiov4, axiod4);
    #40;
    $display("Expected axiov: 1, expected axiod: 0x8180, actual axiov: %b, actual axiod: %h", axiov4, axiod4);
    #40;
    $display("Expected axiov: 1, expected axiod: 0x1e4b, actual axiov: %b, actual axiod: %h", axiov4, axiod4);
    #40;
    $display("Expected axiov: 1, expected axiod: 0x8180, actual axiov: %b, actual axiod: %h", axiov4, axiod4);
    #40;
    $display("Expected axiov: 1, expected axiod: 0x1e4b, actual axiov: %b, actual axiod: %h", axiov4, axiod4);
    #40;
    $display("Expected axiov: 1, expected axiod: 0x8180, actual axiov: %b, actual axiod: %h", axiov4, axiod4);
    #40;

    for (int i = 0; i < 200; i=i+1) begin
      $display("Expected axiov: 1, expected axiod: %h, actual axiov: %b, actual axiod: %h",i, axiov4, axiod4);
      #40;
    end    
    $display("Expected axiov: 0, actual axiov: %b, actual axiod: %h", axiov4, axiod4);
    #40;
    $display("Expected axiov: 0, actual axiov: %b, actual axiod: %h", axiov4, axiod4);
    $finish;
  end

endmodule
`default_nettype wire 
