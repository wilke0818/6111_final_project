`timescale 1ns / 1ps
`default_nettype none

module controller_controller_in
    ( input wire clk    // Clock @ 100 mhz
    , input wire rst
    , input wire data   // Data wire from NES controller
    , output logic latch // Latch wire into NES controller
    , output logic pulse // Pulse wire into NES controller
    , output logic axiov
    , output logic [7:0] buttons  // One-hot encoding of pressed buttons {A, B, SEL, START, UP, DN, L, R}
    );

    enum {WAIT_FOR_LATCH, SEND_LATCH, PULSE_LOW, PULSE_HIGH} state;
    logic [$clog2(800000)-1:0] clk_counter = 0;
    logic [$clog2(800000)-1:0] clk_us_counter = 0;

    logic [3:0] button_count = 0;

    always_ff @(posedge clk)begin
        if (rst)begin
            state <= WAIT_FOR_LATCH;
            clk_counter <= 0;
            clk_us_counter <= 0;
            button_count <= 0;
            buttons <= 0;
            axiov <= 0;
            latch <= 0;
            pulse <= 1;
        end else begin
            case (state)
                WAIT_FOR_LATCH : begin
                    if(clk_counter >= 800000)begin   // 60Hz clock
                        axiov <= 0;
                        latch <= 1;
                        state <= SEND_LATCH;
                        clk_us_counter <= 0;
                        clk_counter <= 0;
                    end else begin
                        latch <= 0;
                        pulse <= 1;
                    end
                end
                
                SEND_LATCH : begin
                    if (clk_us_counter >= 600)begin    // 12us clock
                        latch <= 0;
                        state <= PULSE_LOW;
                        clk_us_counter <= 0;
                    end else
                        clk_us_counter <= clk_us_counter + 1;
                end

                PULSE_LOW : begin
                    if (clk_us_counter >= 300)begin     // 6us wait period
                        pulse <= 0;
                        state <= PULSE_HIGH;
                        clk_us_counter <= 0;
                        buttons <= {buttons[6:0], ~data};  // Add button_pressed to button vector (data low if button is pressed)
                        button_count <= button_count + 1;
                    end else
                        clk_us_counter <= clk_us_counter + 1;
                end

                PULSE_HIGH : begin
                    if (clk_us_counter >= 300)begin     // 6us wait period
                        clk_us_counter <= 0;
                        pulse <= 1;
                        if (button_count >= 8) begin
                            axiov <= 1;
                            button_count <= 0;
                            state <= WAIT_FOR_LATCH;
                        end else
                            state <= PULSE_LOW;
                    end else
                        clk_us_counter <= clk_us_counter + 1;
                end
            endcase
            if (clk_counter < 800000)
                clk_counter <= clk_counter + 1;
        end
    end


endmodule // controller_controller_in
`default_nettype wire
