
`timescale 1ns / 1ps
`default_nettype none

module bland_cksum #(parameter N=2) (
  input wire clk,
  input wire rst,
  input wire axiiv,
  input wire [N-1:0] axiid,
  input wire init_valid,
  input wire [15:0] init_data,
  output logic axiov,
  output logic [15:0] axiod
);

  parameter MAX_COUNT = 16/N;

  logic [15:0] sum;
  logic [15:0] word;
  logic [3:0] count;
  logic last_input;
  logic reset_now;
  logic first_run;
  assign axiov = 1'b1;
  assign axiod = 16'hffff ^ sum;

  always_ff @(posedge clk) begin
    if (~rst) last_input <= axiiv;
    else last_input <= 0;
  end

  always_ff @(posedge clk) begin
    if (rst || reset_now) begin
      sum <= 0;
      word <= 0;
      count <= 0;
      reset_now <= 0;
      first_run <= 1'b1;
    end else begin
      if (axiiv) begin
        if (count < MAX_COUNT -1) begin
          if (init_valid && first_run) begin
            first_run <= 1'b0;
            if (sum + init_data > 17'b0_1111_1111_1111_1111) begin
              sum <= sum + init_data + 1'b1; //add the carry bit
            end else begin
              sum <= sum + init_data;
            end
          end
          count <= count + 1;
          word[15-N*count -: N] <= axiid;
        end else if (count == MAX_COUNT-1) begin
          if (axiid + sum + word > 17'b0_1111_1111_1111_1111) begin
            sum <= sum + axiid + word + 1'b1; //add the carry bit
          end else begin
            sum <= sum + axiid + word;
          end
          count <= 0;
          word <= 0;
        end
      end else begin
        if (last_input) begin //falling edge of axiiv
          reset_now <= 1'b1;
        end else begin
          reset_now <= 0;
        end
      end
    end

  end

endmodule

`default_nettype wire
