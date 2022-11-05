`default_nettype none
`timescale 1ns / 1ps

module firewall_tb;

  /* logics for inputs and outputs */
  logic clk_in;
  logic rst_in;
  logic [1:0] axiid;
  logic axiiv;
  logic axiov;
  logic [1:0] axiod;  /* be sure this is the right bit width! */

  parameter ME = 48'h69_69_5A_06_54_91;

  firewall uut(  .clk(clk_in),
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
    $dumpfile("firewall.vcd"); //file to store value change dump (vcd)
    $dumpvars(0,firewall_tb); //store everything at the current level and below


    clk_in = 0;
    rst_in = 0;
    axiid = 0;
    axiiv = 0;

    #20;
    $display("Starting simulation broadcase to everyone");
    rst_in = 1;
    #20;
    rst_in = 0;
    #20;
    axiiv = 1;
    axiid = 2'b11;
    for (int i = 0; i < 24; i=i+1) begin
      #20; //Destination
    end
    axiid = 2'b00;
    for (int i = 0; i < 24; i=i+1) begin
      #20; //Source
    end
    axiid = 2'b10;
    for (int i = 0; i < 8; i=i+1) begin
      #20;
      $display("Expected axiov: 0, axiov: %b, axiod: %b", axiov, axiod);
      
    end
    #20;    
    $display("Expected axiov: 1, expected axiod: 10, axiov: %b, axiod: %b", axiov, axiod);
    
    axiid = 2'b01;
    #20;
    for (int i = 0; i < 20; i+=1) begin
      $display("Expected axiov: 1, expected axiod: 01, axiov: %b, axiod: %b", axiov, axiod);
      #20;
    end
    #20;
    $display("Starting simulation broadcas  not me");
    rst_in = 1;
    #20;
    rst_in = 0;
    #20;
    axiiv = 1;
    for (int j = 0; j < 24; j=j+1) begin
      axiid = 2'b01;
      #20; //Destination
    end

    axiid = 2'b00;
    for (int i = 0; i < 24; i=i+1) begin
      #20; //Source
    end
    axiid = 2'b01;
    for (int i = 0; i < 8; i=i+1) begin
      $display("Expected axiov: 0, axiov: %b, axiod: %b", axiov, axiod);
      #20;
    end

    $display("Expected axiov: 0, axiov: %b, axiod: %b", axiov, axiod);

    $display("Starting simulation broadcase to me");
    rst_in = 1;
    #20;
    axiiv = 0;
    rst_in = 0;
    #20;
    axiiv = 1;

    axiid = 2'b01;
    #20; //Destination
    axiid = 2'b10;
    #20; //Destination 6
    axiid = 2'b10;
    #20; //Destination
    axiid = 2'b01;
    #20; //Destination 9
    axiid = 2'b01;
    #20; //Destination
    axiid = 2'b10;
    #20; //Destination 6
    axiid = 2'b10;
    #20; //Destination
    axiid = 2'b01;
    #20; //Destination 9
    axiid = 2'b01;
    #20; //Destination
    axiid = 2'b01;
    #20; //Destination 5
    axiid = 2'b10;
    #20; //Destination
    axiid = 2'b10;
    #20; //Destination A
    axiid = 2'b00;
    #20; //Destination
    axiid = 2'b00;
    #20; //Destination 0
    axiid = 2'b01;
    #20; //Destination
    axiid = 2'b10;
    #20; //Destination 6
    axiid = 2'b01;
    #20; //Destination
    axiid = 2'b01;
    #20; //Destination 9
    axiid = 2'b01;
    #20; //Destination
    axiid = 2'b00;
    #20; //Destination 4
    axiid = 2'b10;
    #20; //Destination
    axiid = 2'b01;
    #20; //Destination 9
    axiid = 2'b00;
    #20; //Destination
    axiid = 2'b01;
    #20; //Destination 1


    axiid = 2'b00;
    for (int i = 0; i < 24; i=i+1) begin
      #20; //Source
    end
    axiid = 2'b10;
    for (int i = 0; i < 8; i=i+1) begin
      #20;
      $display("Expected axiov: 0, axiov: %b, axiod: %b", axiov, axiod);      
    end
    #20;
    $display("Expected axiov: 1, expected axiod: 10, axiid: %b, axiov: %b, axiod: %b", axiid, axiov, axiod);
    
    #10;
    axiid = 2'b01;
    #10;
    for (int i = 0; i < 20; i+=1) begin
      $display("Expected axiov: 1, expected axiod: 01, axiov: %b, axiod: %b", axiov, axiod);
      #20;
    end
    #20;
    axiiv = 0;
  $finish;
  end
endmodule

`default_nettype wire
