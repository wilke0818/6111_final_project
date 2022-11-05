`default_nettype none
`timescale 1ns / 1ps

module bitorder_tb;

  /* logics for inputs and outputs */
  logic clk_in;
  logic rst_in;
  logic [1:0] axiid;
  logic axiiv;
  logic axiov;
  logic [1:0] axiod;  /* be sure this is the right bit width! */

  bitorder uut(  .clk(clk_in),
                .rst(rst_in),
                .axiid(axiid),
                .axiiv(axiiv),
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
    $dumpfile("bitorder.vcd"); //file to store value change dump (vcd)
    $dumpvars(0,bitorder_tb); //store everything at the current level and below

    clk_in = 0;
    rst_in = 0;
    axiid = 0;
    axiiv = 0;
    #20;
    rst_in = 1;
    #20;
    rst_in = 0;
    $display("Simulating one byte from lab page");
    #20;
    axiiv = 1;
    axiid = 2'b01;
    #20;
    axiid = 2'b01;
    #20;
    axiid = 2'b01;
    #20;
    axiid = 2'b11;
    #20;
    axiiv = 0;
    $display("axiov: %b, axiod: %b", axiov, axiod);
    #20;
    axiiv = 0;
    $display("axiov: %b, axiod: %b", axiov, axiod);
    #20;
    axiiv = 0;
    $display("axiov: %b, axiod: %b", axiov, axiod);
    #20;
    axiiv = 0;
    $display("axiov: %b, axiod: %b", axiov, axiod);

    #20;
    rst_in = 1;
    #20;
    rst_in = 0;
    $display("Simulating three bytes");
    #20;
    axiiv = 1;
    axiid = 2'b01;
    #20;
    axiid = 2'b01;
    #20;
    axiid = 2'b01;
    #20;
    axiid = 2'b11;
    #20;
    axiid = 2'b00;
    $display("Expected axiod: 11 axiov: %b, axiod: %b", axiov, axiod);
    #20;
    axiid = 2'b01;
    $display("Expected axiod: 01 axiov: %b, axiod: %b", axiov, axiod);
    #20;
    axiid = 2'b10;
    $display("Expected axiod: 01 axiov: %b, axiod: %b", axiov, axiod);
    #20;
    axiid = 2'b10;
    $display("Expected axiod: 01 axiov: %b, axiod: %b", axiov, axiod);
    #20;
    axiid = 2'b11;
    $display("Expected axiod: 10 axiov: %b, axiod: %b", axiov, axiod);
    #20;
    axiid = 2'b00;
    $display("Expected axiod: 10 axiov: %b, axiod: %b", axiov, axiod);
    #20;
    axiid = 2'b11;
    $display("Expected axiod: 01 axiov: %b, axiod: %b", axiov, axiod);
    #20;
    axiid = 2'b01;
    $display("Expected axiod: 00 axiov: %b, axiod: %b", axiov, axiod);
    #20;
    axiiv = 0;
    $display("Expected axiod: 01 axiov: %b, axiod: %b", axiov, axiod);
    #20;
    $display("Expected axiod: 11 axiov: %b, axiod: %b", axiov, axiod);
    #20;
    $display("Expected axiod: 00 axiov: %b, axiod: %b", axiov, axiod);
    #20;
    $display("Expected axiod: 11 axiov: %b, axiod: %b", axiov, axiod);
    #20;
    $display("one later, axiov: %b, axiod: %b", axiov, axiod);
    #20;
    rst_in = 1;
    #20;
    rst_in = 0;
    $display("Simulating one byte and a partial  byte");
    #20;
    axiiv = 1;
    axiid = 2'b01;
    #20;
    axiid = 2'b01;
    #20;
    axiid = 2'b01;
    #20;
    axiid = 2'b11;
    #20;
    axiid = 2'b00;
    $display("Expected axiod: 11 axiov: %b, axiod: %b", axiov, axiod);
    #20;
    axiid = 2'b01;
    $display("Expected axiod: 01 axiov: %b, axiod: %b", axiov, axiod);
    #20;
    axiid = 2'b10;
    axiiv = 0;
    $display("Expected axiod: 01 axiov: %b, axiod: %b", axiov, axiod);
    #20;
    axiiv = 0;
    $display("Expected axiod: 01 axiov: %b, axiod: %b", axiov, axiod);
    #20;
    axiiv = 0;
    $display("Expected axiov: 0 axiov: %b, axiod: %b", axiov, axiod);
    #20;
    axiiv = 0;
    $display("Expected axiod: 0 axiov: %b, axiod: %b", axiov, axiod);
    $finish;
  end
endmodule

`default_nettype wire
