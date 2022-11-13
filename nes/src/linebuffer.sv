`timescale 1ns / 1ps
`default_nettype none


module linebuffer
    ( input wire clk
    , input wire rst
    , input wire axiiv
    , input wire [23:0] axiid
    , output logic axiov
    , output logic axiod
    );

    always_ff @(posedge clk)begin
        is(rst)begin
        end else begin
            // TODO: implement linebuffer
        end
    end

endmodule