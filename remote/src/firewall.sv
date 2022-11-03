`default_nettype none
`timescale 1ns / 1ps

module firewall(
  input wire clk,
  input wire rst,
  input wire axiiv,
  input wire [1:0] axiid,
  output logic axiov,
  output logic [1:0] axiod);

  parameter ALL_DEST = 48'hFFFFFFFFFFFF;
  parameter MY_MAC = 48'h69695A065491;

  logic [47:0] mac;
  logic [6:0] count;
  logic valid;
  
  assign axiod = axiid;
  assign axiov = rst ? 0 : valid && axiiv && count >55;

  always_ff @(posedge clk) begin
    if (rst) begin
     // axiov <= 0;
      mac <= 0;
      count <= 0;
      valid <= 1;
    end else begin
      if (axiiv && valid) begin
        if (count < 24) begin
          mac[47-2*count] = axiid[1];
          mac[46-2*count] = axiid[0];
          count <= count + 1;
        end else if (count == 24) begin
          if (mac != MY_MAC && mac != ALL_DEST) begin
            valid <= 0;
          end
          count <= count + 1;
        end else if (count < 56) begin
          count <= count+1;
        end
      end else begin
   //     axiov <= 0;
        count <= 0;
        valid <= ~axiiv;
      end
    end


  end

endmodule
`default_nettype wire

