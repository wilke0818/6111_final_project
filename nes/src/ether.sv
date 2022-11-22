`default_nettype none
`timescale 1ns / 1ps


module ether #(parameter N=2) (
  input wire clk,
  input wire rst,
  input wire [N-1:0] rxd,
  input wire crsdv,
  output logic axiov,
  output logic [N-1:0] axiod
);

  parameter WAITING = 0;
  parameter INTRO = 1;
  parameter CONTENT = 2;
  parameter FALSE_CARRIER = 3;
 
  parameter PRE_COUNT = (64/N)-1;
 
  logic [1:0] state;
  logic [5:0] count;
  logic [N-1:0] carrier;

  always_ff @(posedge clk) begin

    if (rst) begin
      count <= 0;
      carrier <= 0;
      state <= WAITING;
      axiov <= 0;
      axiod <= 0;
    end else begin
      case(state)
        WAITING : begin
          if (crsdv && N==2 && rxd == 2'b01) begin
            state <= INTRO;
            carrier <= 0;
            count <= 5'd1;
          end else if (crsdv && N==4 && rxd == 4'b0101) begin
            state <= INTRO;
            carrier <= 0;
            count <= 5'd1;
          end
        end
        INTRO : begin
          if (count < PRE_COUNT) begin
            for (int i = 0; i < N; i=i+2) begin
              carrier[i] <= ~(rxd[i +: 2] == 2'b01);
            end
            if (carrier == 0) begin
              count <= count + 1;
            end else begin
              state <= FALSE_CARRIER;
            end
          end else begin
            if (N==2 && rxd == 2'b11) begin
              count <= 0;
              state <= CONTENT;
            end else if (N==4 && rxd == 4'b1101) begin
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
            carrier <= 0;
          end
        end
      endcase
    end
  end


endmodule
`default_nettype wire
