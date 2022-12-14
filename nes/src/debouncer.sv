`timescale 1ns / 1ps
`default_nettype none

// hello. we've written this together in lecture 3!
module debouncer #(parameter CLK_PERIOD_NS = 10,
                   parameter DEBOUNCE_TIME_MS = 5)(
                  input wire clk_in,
                  input wire rst_in,
                  input wire dirty_in,
                  output logic clean_out);
  parameter COUNTER_SIZE = int'($ceil(DEBOUNCE_TIME_MS*1_000_000/CLK_PERIOD_NS));
  parameter COUNTER_WIDTH = $clog2(COUNTER_SIZE);

  logic [COUNTER_WIDTH-1:0] counter;
  logic old_dirty_in;

  always_ff @(posedge clk_in) begin: DINSHIFT
    old_dirty_in <= dirty_in;
  end

  always_ff @(posedge clk_in) begin: MAINDEBOUNCE
    if (rst_in) begin
      counter <= 0;
      clean_out <= dirty_in;
    end else begin
      if (dirty_in != old_dirty_in) begin
        counter <= 0;
      end else if (counter == COUNTER_SIZE)begin
        clean_out <= dirty_in;
      end else begin
        counter <= counter + 1;
      end
    end
  end
endmodule
`default_nettype wire
