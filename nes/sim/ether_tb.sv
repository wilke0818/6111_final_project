`default_nettype none
`timescale 1ns / 1ps


module ether_tb;

  /* logics for inputs and outputs */
  logic clk_in;
  logic rst_in;
  logic [3:0] rxd;
  logic crsdv;
  logic axiov;
  logic [3:0] axiod;  /* be sure this is the right bit width! */

  ether #(.N(4)) uut(  .clk(clk_in),
              .rst(rst_in),
              .rxd(rxd),
              .crsdv(crsdv),
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
    $dumpfile("ether.vcd"); //file to store value change dump (vcd)
    $dumpvars(0,ether_tb); //store everything at the current level and below
    clk_in = 0;
    rst_in = 0;
    rxd = 0;
    crsdv = 0;
    #20;
    rst_in = 1;
    #20;
    rst_in = 0;
    crsdv = 1;
    $display("Simple valid input");
    #20;
    for (int i = 0; i < 15; i++)begin
      rxd = 4'b0101;
      #20;
    end

    rxd = 4'b1101;
    #20;

    for (int j = 0; j < 5; j++) begin
      rxd = 4'b1010;
      #15;
      $display("rxd: %b and axiod: %2b with axiov as %b", rxd, axiod, axiov);
      #5;
      rxd = 4'b0101;
      #15;
      $display("rxd: %b and axiod: %2b with axiov as %b", rxd, axiod, axiov);
      #5;
    end
    crsdv = 0;

    $display("We goofed the preamble");
    #15;
    for (int i = 0; i < 13; i++)begin
      rxd = 4'b0101;
      #20;
    end
    rxd = 4'b0000;
    #20;
    for (int i = 14; i < 15; i++)begin
      rxd = 4'b1101;
      #20;
    end 

    rxd = 4'b1111;
    #20;

    for (int j = 0; j < 5; j++) begin
      rxd = 4'b1100;
      #15;
      $display("rxd: %b and axiod: %2b with axiov as %b", rxd, axiod, axiov);
      #5;
      rxd = 4'b0101;
      #15;
      $display("rxd: %b and axiod: %2b with axiov as %b", rxd, axiod, axiov);
      #5;
    end

    crsdv = 0;

    $display("We goofed the SFD");
    #15;
    for (int i = 0; i < 15; i++)begin
      rxd = 4'b0101;
      #20;
    end

    rxd = 4'b1010;
    #20;

    for (int j = 0; j < 5; j++) begin
      rxd = 4'b1011;
      #15;
      $display("rxd: %b and axiod: %2b with axiov as %b", rxd, axiod, axiov);
      #5;
      rxd = 4'b0111;
      #15;
      $display("rxd: %b and axiod: %2b with axiov as %b", rxd, axiod, axiov);
      #5;
    end

    $display("Finishing Sim"); //print nice message
    $finish;
  end

endmodule
`default_nettype wire
