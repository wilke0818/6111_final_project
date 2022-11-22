`default_nettype none
`timescale 1ns / 1ps

module cksum_tb;

  /* logics for inputs and outputs */
  logic clk_in;
  logic rst_in;
  logic [3:0] axiid;
  logic axiiv;
  logic done;
  logic kill;  /* be sure this is the right bit width! */

  cksum uut(  .clk(clk_in),
              .rst(rst_in),
              .axiid(axiid),
              .axiiv(axiiv),
              .done(done),
              .kill(kill));

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
    $dumpfile("cksum.vcd"); //file to store value change dump (vcd)
    $dumpvars(0,cksum_tb); //store everything at the current level and below

    clk_in = 0;
    rst_in = 0;
    axiid = 2'b0;
    axiiv = 0;
    #20;
    rst_in = 1;
    #20;
  
    rst_in = 0;
    #100;
    $display("Simulating partial data");
    $display("axiiv: %b, axiid: %b, done: %b, kill: %b", axiiv, axiid, done, kill);
    for (int i = 0; i < 5; i++) begin
      axiiv = 1;
      axiid = 4'b0;
      #15;
      $display("axiiv: %b, axiid: %b, done: %b, kill: %b", axiiv, axiid, done, kill);
      #5;
      axiiv = 1;
      axiid = 3'b0101;
      #15;
      $display("axiiv: %b, axiid: %b, done: %b, kill: %b", axiiv, axiid, done, kill);
      #5;
      axiiv = 1;
      axiid = 4'b1010;
      #15;
      $display("axiiv: %b, axiid: %b, done: %b, kill: %b", axiiv, axiid, done, kill);
      #5;
      axiiv = 1;
      axiid = 4'b1111;
      #15;
      $display("axiiv: %b, axiid: %b, done: %b, kill: %b", axiiv, axiid, done, kill);
      #5;
    end
    axiiv = 0;
    #20;
    $display("axiiv: %b, axiid: %b, done: %b, kill: %b", axiiv, axiid, done, kill);
    #20;
    $display("axiiv: %b, axiid: %b, done: %b, kill: %b", axiiv, axiid, done, kill);
    #20;
    $display("axiiv: %b, axiid: %b, done: %b, kill: %b", axiiv, axiid, done, kill);
    #20;
    $display("axiiv: %b, axiid: %b, done: %b, kill: %b", axiiv, axiid, done, kill);
   
    #10;
    axiiv = 1;
    #10;
    #20;
    $display("axiiv: %b, axiid: %b, done: %b, kill: %b", axiiv, axiid, done, kill);
    #20;
    
    
    $display("Simulating real data");
    #20;
    rst_in = 1;
    axiiv = 0;
    #20;
    rst_in = 0;
    #20;
    axiiv = 1;
    axiid = 4'b0101;
    for (int i = 0; i < 60; i++) begin
      #20;
    end

    $display("axiiv: %b, axiid: %b, done: %b, kill: %b", axiiv, axiid, done, kill);
    
    //A6C0DAC3
    axiid = 4'ha;
    #20;
    axiid = 4'h6;
    #20;
    axiid = 4'hc;
    #20;
    axiid = 4'h0;
    #20;
    axiid = 4'hd;
    #20;
    axiid = 4'ha;
    #20;
    axiid = 4'hc;
    #20;
    axiid = 4'h3;
    #20;

    #5;
    axiiv = 0;
    #15;
    $display("axiiv: %b, axiid: %b, done: %b, kill: %b", axiiv, axiid, done, kill);
    #20;
    $display("axiiv: %b, axiid: %b, done: %b, kill: %b", axiiv, axiid, done, kill);

    axiiv = 1;
    #20;
    $display("axiiv: %b, axiid: %b, done: %b, kill: %b", axiiv, axiid, done, kill);

    $finish;
  end
endmodule

`default_nettype wire
