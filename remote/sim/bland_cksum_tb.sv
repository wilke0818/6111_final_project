`default_nettype none
`timescale 1ns / 1ps

module bland_cksum_tb;
  
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
  logic init_valid;
  logic [15:0] init_data;

  bland_cksum #(.N(4)) uut4
               (.clk(clk_in),
                .rst(rst_in),
                .axiid(axiid4),
                .axiiv(axiiv4),
                .init_valid(init_valid),
                .init_data(init_data),
                .axiov(axiov4),
                .axiod(axiod4));


  always begin
    #20; //25Mhz
    clk_in = !clk_in;
  end

  initial begin
    $display("Starting Sim"); //print nice message
    $dumpfile("bland_cksum.vcd"); //file to store value change dump (vcd)
    $dumpvars(0,bland_cksum_tb); //store everything at the current level and below
    

    clk_in = 0;
    rst_in = 0;
 //   axiid = 0;
 //   axiiv = 0;
    axiid4 = 0;
    axiiv4 = 0;
    init_data = 0;
    init_valid = 0;
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
    axiiv4 = 0;
    $display("Expected axiod: 0xb861, actual axiod: %h", axiod4);
    #80;
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
    

    axiid4 = 4'hb;
    #40;
    axiid4 = 4'h8;
    #40;
    axiid4 = 4'h6;
    #40;
    axiid4 = 4'h1;
    #40;
    axiiv4 = 0;
    $display("Expected axiod: 0x0000, actual axiod: %h", axiod4);

    axiiv4 = 1;
    axiid4 = 4'hb;
    init_valid = 1;
    init_data = 16'h0001;
    #40;
    axiid4 = 4'h8;
    #40;
    axiid4 = 4'h6;
    #40;
    axiid4 = 4'h1;
    #40;
    axiiv4 = 0;
    $display("Expected axiod: 0x479d, actual axiod: %h", axiod4);
    $finish;
  end

endmodule
`default_nettype wire 
