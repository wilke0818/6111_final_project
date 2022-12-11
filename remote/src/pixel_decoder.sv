`timescale 1ns / 1ps
`default_nettype none

module pixel_decoder
    ( input wire clk
    , input wire rst
    , input wire axiiv
    , input wire [15:0] axiid
    , output logic axiov
    , output logic [11:0] axiod
    , output logic [7:0] line_y
    );

    enum {IDLE, DATA_IN} state;

    always_ff @(posedge clk)begin
        if (rst)begin
            axiov <= 0;
            state <= IDLE;
        end else begin
            case (state)
                IDLE : begin
                    if (axiiv)begin
                        line_y <= axiid[15:8];
                        state <= DATA_IN;
                    end
                end

                DATA_IN : begin
                    if (axiiv)begin
                        axiov <= 1;
                        axiod <= axiid[15:4];
                    end else begin
                        axiov <= 0;
                        state <= IDLE;
                    end
                end

                /* IF WE ARE SENDING 12-bit COLOR, USE THIS:
                IDLE : begin
                    if (axiiv)begin
                        line_y <= axiid[15:8];
                        pixel_buffer1 <= {4'b0, axiid[7:0]};
                        state <= DATA_IN_0;
                    end
                end

                DATA_IN_0 : begin
                    pixel_buffer1 <= {pixel_buffer1[7:0], axiid[15:12]};
                    pixel_buffer2 <= axiid[11:0];
                    state <= DATA_IN_1;
                end

                DATA_IN_1 : begin
                    pixel_buffer1 <= axiid[15:4];
                    pixel_buffer2 <= {8'b0, axiid[3:0]};
                    state <= DATA_IN_2;
                end

                DATA_IN_2 : begin
                    pixel_buffer1 <= {4'b0, axiid[7:0]};
                    pixel_buffer2 <= {pixel_buffer2[3:0], axiid[15:8]};
                    state <= DATA_IN_0;
                end
                */
           endcase
        end
    end
    endmodule // pixel_decoder
