`timescale 1ns / 1ps
`default_nettype none


module ethertype #(parameter N=2) (
  input wire clk,
  input wire rst,
  input wire [N-1:0] axiid,
  input wire axiiv,
  output logic axiov,
  output logic axiod //Size will depend on number of states/supported ethertypes
);

  parameter COUNT_TOTAL = 16/N;
  parameter COUNT_BITS = $clog2(COUNT_TOTAL);


  logic [COUNT_BITS:0] count;
  logic [15:0] ethertype;

  always_comb begin
    if (count == COUNT_TOTAL-1) begin
      if ({ethertype[15:N],axiid} == 16'h0800) begin //IPv4
        axiod = 1'b0;
        axiov = 1'b1;
      end else if ({ethertype[15:N],axiid} == 16'h0806) begin //ARP
        axiod = 1'b1;
        axiov = 1'b1;
      end
    end else if (~axiiv) begin
      axiov = 1'b0;
    end
  end
  
  always_ff @(posedge clk) begin
    if (rst) begin
      count <= 0;
      ethertype <= 0;
    end else begin
      if (axiiv) begin
        if (count < COUNT_TOTAL) begin
          count <= count + 1;
          ethertype[15-N*count -: N] <= axiid;
        end else if (count == COUNT_TOTAL) begin
          count <= count+1;
        end
      end else begin
        count <= 0;
        ethertype <= 0;
      end
    end

  end

endmodule

`default_nettype wire
