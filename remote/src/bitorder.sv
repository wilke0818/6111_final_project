`default_nettype none
`timescale 1ns / 1ps


module bitorder #(parameter N=2)(
  input wire clk,
  input wire rst,
  input wire axiiv,
  input wire [N-1:0] axiid,
  output logic axiov,
  output logic [N-1:0] axiod
);

  parameter COUNT_MAX = (8/N)-1;
  parameter N_SHIFT = $clog2(N);
  logic [$clog2(8/N)-1:0] count;
  logic [7:0] buffer1;
  logic [7:0] buffer2;
  logic select;
  logic [$clog2(8/N)-1:0] out_count;
//  logic [1:0] out_count;

  always_ff @(posedge clk) begin
    if (~rst) begin
      if (count == COUNT_MAX && axiiv) begin
        axiov <= 1'b1;
        out_count <= COUNT_MAX;
        axiod <= axiid;
      end else if (out_count > 0) begin
        axiov <= 1'b1;
        out_count <= out_count -1;
        for (int i = 0; i < COUNT_MAX; i = i + 1) begin
          if (out_count == i+1) axiod <= select ? buffer1[2*i +: N] : buffer2[2*i +: N];
        end
//        case (out_count)
//          2'b01 : axiod <= select ? buffer1[1:0] : buffer2[1:0];
//          2'b10 : axiod <= select ? buffer1[3:2] : buffer2[3:2];
//          2'b11 : axiod <= select ? buffer1[5:4] : buffer2[5:4];
//        endcase
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
          for (int i = 0; i < N; i=i+1) begin
            buffer1[N*count+i] <= axiid[i];
          end
          count <= count + 1;
          select <= count == COUNT_MAX ? ~select : select;
        end else begin
          for (int i = 0; i < N; i=i+1) begin
            buffer2[N*count+i] <= axiid[i];
          end
          count <= count + 1;
          select <= count == COUNT_MAX ? ~select : select;
        end
      end
    end
  end

endmodule
`default_nettype wire

