`default_nettype none
`timescale 1ns / 1ps


module ethertx_tb;

  /* logics for inputs and outputs */
  logic clk_in;
  logic rst_in;
  logic [3:0] axiid;
  logic axiiv;
  logic [47:0] my_mac = 48'h12_34_56_78_90_AB;
  logic [47:0] dest_mac = 48'hFF_FF_FF_FF_FF_FF;
  logic [15:0] etype = 16'hF0F0;
  logic axiov;
  logic [3:0] axiod;  /* be sure this is the right bit width! */

  ethernet_tx #(.N(4)) uut(  
              .clk(clk_in),
              .rst(rst_in),
              .axiid(axiid),
              .axiiv(axiiv),
              .my_mac(my_mac),
              .dest_mac(dest_mac),
              .etype(etype),
              .axiov(axiov),
              .axiod(axiod));

  /* An always block in simulation **always** runs in the background.
   * This is useful to simulate a clock for sequential testbenches:
   *    - every 5ns, make clk be !clk
   */
  always begin
    #10;
    clk_in = !clk_in;
  end

  /* Make sure to initialize the clock as well! */
  
  initial begin
    $display("Starting Sim"); //print nice message
    $dumpfile("ethertx.vcd"); //file to store value change dump (vcd)
    $dumpvars(0,ethertx_tb); //store everything at the current level and below
    clk_in = 0;
    axiiv = 0;
    rst_in = 0;
    #20;
    rst_in = 1;
    #20;
    rst_in = 0;
    $display("Simple valid input");
    #20;
    axiiv <= 1;
    #1900;
    axiiv <= 0;
    #200;
    axiiv <= 1;
    #1900;
    axiiv <= 0;
    #200;

    $display("Finishing Sim"); //print nice message
    $finish;
  end

endmodule
`default_nettype wire
