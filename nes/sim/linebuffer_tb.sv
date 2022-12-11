`default_nettype none
`timescale 1ns / 1ps

module linebuffer_tb;

  /* logics for inputs and outputs */
  logic clk_in;
  logic rst_in;
  logic axiiv;
  logic [23:0] axiid;
  logic axiov;
  logic [11:0] axiod;  /* be sure this is the right bit width! */

  linebuffer uut
      (.clk(clk_in),
       .rst(rst_in),
       .axiiv(axiiv),
       .axiid(axiid),
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
    $dumpfile("linebuffer.vcd"); //file to store value change dump (vcd)
    $dumpvars(0,linebuffer_tb); //store everything at the current level and below

    clk_in = 0;
    rst_in = 0;
    axiid = 0;
    axiiv = 0;
    #20;
    rst_in = 1;
    #20;
    rst_in = 0;
    #20;
    axiiv = 1;
    axiid = 24'b1111_1010_0000_1100_0011_1101;
    #20000;
    $finish;
  end
endmodule

`default_nettype wire
