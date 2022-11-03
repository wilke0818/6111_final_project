`default_nettype none
`timescale 1ns / 1ps


module bitorder(
  input wire clk,
  input wire rst,
  input wire axiiv,
  input wire [1:0] axiid,
  output logic axiov,
  output logic [1:0] axiod
);

  logic [1:0] count;
  logic [7:0] buffer1;
  logic [7:0] buffer2;
  logic select;
  logic [1:0] out_count;

  always_ff @(posedge clk) begin
    if (~rst) begin
      if (count == 3 && axiiv) begin
        axiov <= 1'b1;
        out_count <= 2'd3;
        axiod <= axiid;
      end else if (out_count > 0) begin
        axiov <= 1'b1;
        out_count <= out_count -1;
        case (out_count)
          2'b01 : axiod <= select ? buffer1[1:0] : buffer2[1:0];
          2'b10 : axiod <= select ? buffer1[3:2] : buffer2[3:2];
          2'b11 : axiod <= select ? buffer1[5:4] : buffer2[5:4];
        endcase
      end else begin
        axiov <= 1'b0;
      end
    end else begin
      out_count <= 0;
      axiov <= 0;
    end
  end

  always_ff @(posedge clk) begin
    if (rst) begin
      count <= 0;
      buffer1 <= 0;
      buffer2 <= 0;
      select <= 0;
    end else begin
      if (axiiv) begin
        if (~select) begin
          buffer1[2*count+1] <= axiid[1];
          buffer1[2*count] <= axiid[0];
          count <= count + 1;
          select <= count == 3 ? ~select : select;
        end else begin
          buffer2[2*count+1] <= axiid[1];
          buffer2[2*count] <= axiid[0];
          count <= count + 1;
          select <= count == 3 ? ~select : select;
        end
      end else begin
        count <= 0;
      end
    end
  end

endmodule
`default_nettype wire

