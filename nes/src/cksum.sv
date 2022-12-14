`default_nettype none
`timescale 1ns / 1ps

module cksum(
  input wire clk,
  input wire rst,
  input wire [1:0] axiid,
  input wire axiiv,
  output logic done,
  output logic kill
);

  parameter ETHERNET_CHECK_SUM = 32'h38_fb_22_84;

  logic [31:0] check_sum_out;
  logic check_valid_out;
  logic last_input;
  logic reset_now;

  logic prev_done, prev_kill;

  crc32 check_sum(
    .clk(clk),
    .rst(rst || reset_now),
    .axiiv(axiiv),
    .axiid(axiid),
    .axiov(check_valid_out),
    .axiod(check_sum_out));

  always_comb begin
    if (rst) begin
      done = 0;
      kill = 0;
    end else begin
      if (axiiv) begin
        done = 0;
        kill = 0;
      end else begin
        if (last_input) begin //falling edge of axiiv
          done = 1'b1;
          //reset_now <= 1'b1;
          kill = check_sum_out != ETHERNET_CHECK_SUM;
        end else begin
          done = prev_done;
          kill = prev_kill;
        end
      end
    end
  end

  always_ff @(posedge clk) begin
    if (~rst) last_input <= axiiv;
    else last_input <= 0;
  end

  always_ff @(posedge clk) begin
    if (rst) begin
    //  done <= 0;
    //  kill <= 0;
      reset_now <= 0;
      prev_done <= 0;
      prev_kill <= 0;
    end else begin
      prev_done <= done;
      prev_kill <= kill;
      if (~axiiv) begin
        if (last_input) begin //falling edge of axiiv
         // done <= 1'b1;
          reset_now <= 1'b1;
        //  kill <= check_sum_out != ETHERNET_CHECK_SUM;
        end else begin
          reset_now <= 0;
        end
      end
    end
  end

endmodule

`default_nettype wire
