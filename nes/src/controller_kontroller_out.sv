`timescale 1ns / 1ps
`default_nettype none

module controller_kontroller_out
    ( input wire clk    // Clock @ 100 mhz
    , input wire rst
    , input wire latch // Latch wire from NES
    , input wire pulse // Pulse wire from NES
    , input wire axiiv
    , input wire [7:0] buttons  // One-hot encoding of pressed buttons {A, B, SEL, START, UP, DN, L, R}
    , output logic data   // Data wire into NES
    );

    enum {WAIT_FOR_LATCH, WAIT_LATCH_END, PULSE_HIGH, PULSE_WAIT, PULSE_LOW} state;
    logic [15:0] clk_counter = 0;

    logic [3:0] button_count = 4'd7;

    logic [7:0] buttons_pressed;  // Keep separate buttons_pressed vector in case input isn't valid when we are polled

    always_ff @(posedge clk)begin
        if (axiiv)
            buttons_pressed <= buttons;
    end

`define DEBOUNCE_CONSTANT 20
    logic[31:0] counter;
    logic pulse_debounced;

    always_ff @(posedge clk) begin: DEBOUNCE
        if (pulse != pulse_debounced) begin
            if (counter >= `DEBOUNCE_CONSTANT) begin
                pulse_debounced <= pulse;
                counter <= 0;
            end else counter <= counter + 1;
        end else begin
            counter <= 0;
        end
    end /* DEBOUNCE */

    always_ff @(posedge clk)begin
        if (rst)begin
            state <= WAIT_FOR_LATCH;
            data <= 1;
            clk_counter <= 0;
            button_count <= 4'd7;
        end else begin
            case (state)
                WAIT_FOR_LATCH : begin
                    if (latch)begin
                        state <= WAIT_LATCH_END;
                        data <= 1;
                    end
                end

                WAIT_LATCH_END : begin
                    if (~latch)begin
                        data <= ~buttons_pressed[7];
                        state <= PULSE_HIGH;
                    end
                end

                PULSE_HIGH : begin
                    if(~pulse_debounced)begin
                        state <= PULSE_WAIT;
                        clk_counter <= 0;
                    end
                end

                PULSE_WAIT : begin
                    if (clk_counter >= 900)begin  // Arbitrary small delay, so we don't change button data_out before it is read
                        if (button_count > 0)begin
                            button_count <= button_count - 1;
                            state <= PULSE_LOW;
                        end else begin
                            data <= 1;
                            state <= WAIT_FOR_LATCH;
                            button_count <= 4'd7;
                        end
                    end else
                        clk_counter <= clk_counter + 1;
                end

                PULSE_LOW : begin
                    data <= ~buttons_pressed[button_count];
                    if (pulse_debounced)begin
                        state <= PULSE_HIGH;
                    end
                end
            endcase
            
        end
    end


endmodule // controller_kontroller_out
`default_nettype wire
