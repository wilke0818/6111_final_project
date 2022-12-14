`timescale 1ns / 1ps
`default_nettype none

`define IDLE 0
`define DATA_IN 1


module framebuffer
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
    , output logic [15:0] bram_addr
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
                if (state == `IDLE)begin
		        bram_addr <= liney*FRAME_WIDTH;
		        bram_data_in <= axiid;
		        axiov <= 1;
		        hcount <= 1;
		        state <= `DATA_IN;
		 end else if (state == `DATA_IN) begin
		     if(frame_done)begin
		         hcount <= 0;
		         liney <= 0;
		     end else begin
		        axiov <= 1;
		        bram_addr <= (liney*FRAME_WIDTH) + hcount;
		        bram_data_in <= axiid; //12'b1111_0000_0000;
		        if (hcount >= (FRAME_WIDTH-1))begin
			    hcount <= 0;
			    // state <= `IDLE;
			    // axiov <= 0;
			    
			    if (liney < (FRAME_HEIGHT-1))begin
		    		     liney <= liney + 1;
		            end else begin
		    		     liney <= 0;
		    	    end
			end else
				hcount <= hcount + 1;
		      end
		 end
                
            end else begin
                if(frame_done)begin
		         hcount <= 0;
		         liney <= 0;
		     end
            /*
                if (liney < 240)begin
    		     liney <= liney + 1;
    		 end else begin
    		     liney <= 0;
    		 end
                state <= `IDLE;
                */
                axiov <= 0;
            end
        end
    end
endmodule
