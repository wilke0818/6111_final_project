`timescale 1ns / 1ps
`default_nettype none

module camera(
  input wire cam_clk_in,
  input wire vsync_in,
  input wire href_in,
  input wire [7:0] pixel_in,

  input wire clk_65mhz,
  output logic jbclk,
  output logic jblock,
  output logic [15:0] pixel_out,
  output logic pixel_valid_out,
  output logic frame_done_out
  );

  /* Camera Reset */
  parameter STARTUP_DELAY = 65_000_000;
  logic [25:0] startup_counter;
  always_ff @(posedge clk_65mhz) begin
      if (startup_counter == STARTUP_DELAY) jblock <= 1;
      else begin
          jblock <= 0;
          startup_counter <= startup_counter + 1;
      end
  end

  /* XCLK Generation */
  logic xclk;
  logic[1:0] xclk_count;
  always_ff @(posedge clk_65mhz) begin
    xclk_count <= xclk_count + 1;
  end
  assign jbclk = (xclk_count > 1);

  /* Pixel Read State Machine */
  localparam WAIT_FRAME_START = 0;
  localparam ROW_CAPTURE = 1;
  logic [1:0] fsm_state = 0;
  logic pixel_half = 0;

	always_ff @(posedge cam_clk_in) begin
    case(fsm_state)
      WAIT_FRAME_START: begin //wait for VSYNC
        fsm_state <= (~vsync_in) ? ROW_CAPTURE : WAIT_FRAME_START;
        frame_done_out <= 0;
        pixel_valid_out <= 0; //bad spot reading junk at the vsynch spot
        pixel_half <= 0;
      end

      ROW_CAPTURE: begin
        fsm_state <= vsync_in ? WAIT_FRAME_START : ROW_CAPTURE;
        frame_done_out <= vsync_in ? 1 : 0;
        pixel_valid_out <= (href_in && pixel_half) ? 1 : 0;
        if (href_in) begin
          pixel_half <= ~ pixel_half;
          if (pixel_half) pixel_out[7:0] <= pixel_in;
          else pixel_out[15:8] <= pixel_in;
        end
      end
    endcase
  end
endmodule

`default_nettype wire
