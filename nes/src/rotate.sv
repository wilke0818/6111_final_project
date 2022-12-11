module rotate (
  input wire cam_clk_in,

  input wire valid_pixel_in,
  output logic valid_pixel_out,

  input wire [15:0] pixel_in,
  output logic [15:0] pixel_out,

  input wire frame_done_in,
  output logic [16:0] pixel_addr_in
  );

  logic [8:0] pixel_count;

  always_ff @(posedge cam_clk_in)begin
    valid_pixel_out <= valid_pixel_in;
    pixel_out <= pixel_in;
    if (frame_done_in)begin
      pixel_addr_in <= 240*319;
      pixel_count <= 319;
    end else if (valid_pixel_in)begin
      if (pixel_count==0)begin
        pixel_addr_in <= pixel_addr_in + 1 + 240*319; //up by one
        pixel_count <= 319;
      end else begin
        pixel_addr_in <= pixel_addr_in - 240;
        pixel_count <= pixel_count - 1;
      end
    end
  end
endmodule
