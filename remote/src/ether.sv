`default_nettype none
`timescale 1ns / 1ps


module ether(
  input wire clk,
  input wire rst,
  input wire [1:0] rxd,
  input wire crsdv,
  output logic axiov,
  output logic [1:0] axiod
);

  parameter WAITING = 0;
  parameter INTRO = 1;
  parameter CONTENT = 2;
  parameter FALSE_CARRIER = 3;
  
  logic [1:0] state;
  logic [5:0] count;

  always_ff @(posedge clk) begin

    if (rst) begin
      state <= WAITING;
      axiov <= 0;
      axiod <= 0;
    end else begin
      case(state)
        WAITING : begin
          if (crsdv && rxd == 2'b01) begin
            state <= INTRO;
            count <= 5'd1;
          end
        end
        INTRO : begin
          if (count < 5'd31) begin
            if (rxd == 2'b01) begin
              count <= count + 1;
            end else begin
              state <= FALSE_CARRIER;
            end
          end else begin
            if (rxd == 2'b11) begin
              count <= 0;
              state <= CONTENT;
            end else begin     
              state <= FALSE_CARRIER;
            end
          end
        end
        CONTENT : begin
          if (crsdv) begin
            axiod <= rxd;
            axiov <= 1'b1;
          end else begin
            axiov <= 1'b0;
            state <= WAITING;
          end
        end
        FALSE_CARRIER : begin
          if (~crsdv) begin
            state <= WAITING;
          end
        end
      endcase
    end
  end


endmodule
`default_nettype wire
