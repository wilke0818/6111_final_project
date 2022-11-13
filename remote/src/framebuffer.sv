`timescale 1ns / 1ps
`default_nettype none


module framebuffer
    ( input wire clk
    , input wire rst
    , input wire axiiv
    , input wire [23:0] axiid
    , output logic axiov
    , output logic axiod
    );

    // 12x(240x256) BRAM

    always_ff @(posedge clk)begin
        is(rst)begin
        end else begin
            // 
        end
    end

endmodule