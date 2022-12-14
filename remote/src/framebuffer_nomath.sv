`timescale 1ns / 1ps
`default_nettype none

`define IDLE 0
`define DATA_IN 1


module framebuffer_nomath
    #(parameter FRAME_WIDTH = 240
    , parameter FRAME_HEIGHT = 320
    )
    ( input wire clk
    , input wire rst
    , input wire axiiv
    , input wire [11:0] axiid
    , input wire frame_done
    , input wire [15:0] line_y
    , output logic axiov
    , output logic [16:0] bram_addr
    , output logic [11:0] bram_data_in
    , output logic [15:0] d_hcount
    , output logic [15:0] d_liney
    );

    
    logic state;
    logic [15:0] hcount = 0;
    logic [15:0] liney = 0;
    
    assign d_hcount = hcount;
    assign d_liney = liney;

    always_ff @(posedge clk)begin
        if(rst)begin
            state <= `IDLE;
            axiov <= 0;
            hcount <= 0;
            liney <= 0;
        end else begin
            if (axiiv)begin
                axiov <= 1;
                if(frame_done)begin
		    bram_addr <= 0;
		end else
                   bram_addr <= bram_addr + 1;
                  
                bram_data_in <= axiid;
                
            end else begin
                if(frame_done)begin
		         bram_addr <= 0;
		     end
                axiov <= 0;
            end
        end
    end
endmodule
