`timescale 1ns / 1ps
`default_nettype none


module framebuffer
    #(parameter FRAME_WIDTH = 256)
    ( input wire clk
    , input wire rst
    , input wire axiiv
    , input wire [11:0] axiid
    , input wire [7:0] line_y
    , output logic axiov
    , output logic [15:0] bram_addr
    , output logic bram_data_in
    );

    
    enum {IDLE, DATA_IN} state;
    logic [15:0] hcount = 0;

    always_ff @(posedge clk)begin
        if(rst)begin
            state <= IDLE;
            axiov <= 0;
            hcount <= 0;
        end else begin
            if (axiiv)begin
                case (state)
                    IDLE : begin
                        bram_addr <= line_y*FRAME_WIDTH;
                        bram_data_in <= axiid;
                        axiov <= 1;
                        hcount <= 1;
                        state <= DATA_IN;
                    end
                    
                    DATA_IN : begin
                        bram_addr <= line_y*FRAME_WIDTH + hcount;
                        bram_data_in <= axiid;
                        hcount <= hcount + 1;
                    end
                endcase
            end else begin
                state <= IDLE;
                axiov <= 0;
            end
        end
    end
endmodule
