`timescale 1ns / 1ps
`default_nettype none

module top_level(
/******** 4 bit *************
  input wire clk_100mhz, //clock @ 100 mhz
  input wire btnc, //btnc (used for reset)
  input wire btnr,
  input wire eth_rxck,
  output logic eth_txck, //should this be input?
  input wire [1:0] eth_rxd,
  input wire eth_rxctl,
  output wire eth_txctl,
  output wire [1:0] eth_txd,
  output logic eth_rst_b
 // output logic [15:0] led, //just here for the funs

 // output logic [7:0] an,
 // output logic ca,cb,cc,cd,ce,cf,cg
 
 *******************************/
 
      input wire clk
	, input wire btnc
	, input wire btnr
    , input wire [7:0] ja  // lower 8 bits of data from camera
    , input wire [2:0] jb  // upper 3 bits from camera (return clock, vsync, hsync)
    , output logic jbclk
    , output logic jblock
	, output logic [15:0] led
	, input wire eth_crsdv
	, input wire [1:0] eth_rxd
	, output logic eth_txen
	, output logic [1:0] eth_txd
	, output logic eth_rstn
	, output logic eth_refclk
  );
  
  assign led[15:3] = 0;
  assign led[2] = eth_crsdv;
  assign led[1:0] = eth_rxd;
  
  // assign eth_txctl = 0;
  // assign eth_txd = 0;
  parameter N = $bits(eth_txd);
  parameter MY_MAC = 48'h12_34_56_78_90_AB;
  parameter DEST_MAC = 48'hFF_FF_FF_FF_FF_FF;

  /* have btnd control system reset */
  logic sys_rst;
  assign sys_rst = btnc;
  // assign eth_rst_b = ~sys_rst;
  assign eth_rstn = ~sys_rst;


  logic l;
  logic l2;

/*
  ila il
      ( .clk(eth_txck)
      , .probe0(eth_txctl)
      , .probe1(eth_txd)
      );
*/
  //TODO: make these a 25MHz clock when we move to a video board
  clk_wiz_0 ether_clk1(
    .clk_in1(clk),
    .clk_out1(eth_refclk)
  );
/*
  network_stack #(.N(N)) network_m (
    .clk(eth_rxck),
    .rst(sys_rst),
    .eth_rxd(eth_rxd),
    .eth_txd(eth_txd),
    .eth_crsdv(eth_rxctl),
    .eth_txen(eth_txctl),
    .mac(MY_MAC)
  );
  */
  // ETHERNET TEST
  ethernet_tx #(.N(N)) ethernet_tx_m(
  .clk(eth_refclk),             // clock @ 25 or 50 mhz
  .rst(sys_rst),             // btnc (used for reset)
  .axiid(0),   // AXI Input Data
  .axiiv(btnr),           // AXI Input Valid
  .my_mac(MY_MAC),   // MAC address of this FPGA
  .dest_mac(DEST_MAC), // MAC address of destination device
  .etype(16'hF0F0),    // Ethernet type
  .axiov(eth_txen),         // Transmitting valid data
  .axiod(eth_txd) // Data being transmitted
  );


  // Camera module
  logic cam_clk_buff, cam_clk_in; //returning camera clock
  logic vsync_buff, vsync_in; //vsync signals from camera
  logic href_buff, href_in; //href signals from camera
  logic [7:0] pixel_buff, pixel_in; //pixel lines from camera
  logic [15:0] cam_pixel; //16 bit 565 RGB image from camera
  logic valid_pixel; //indicates valid pixel from camera
  logic frame_done; //indicates completion of frame from camera

  logic valid_pixel_rotate;
  logic [15:0] pixel_rotate;
  logic [16:0] pixel_addr_in;
  
  //Clock domain crossing to synchronize the camera's clock
  //to be back on the 65MHz system clock, delayed by a clock cycle.
  always_ff @(posedge clk_65mhz) begin
    cam_clk_buff <= jb[0]; //sync camera
    cam_clk_in <= cam_clk_buff;
    vsync_buff <= jb[1]; //sync vsync signal
    vsync_in <= vsync_buff;
    href_buff <= jb[2]; //sync href signal
    href_in <= href_buff;
    pixel_buff <= ja; //sync pixels
    pixel_in <= pixel_buff;
  end

  //Controls and Processes Camera information
  camera camera_m(
    //signal generate to camera:
    .clk_65mhz(clk_65mhz),
    .jbclk(jbclk),
    .jblock(jblock),
    //returned information from camera:
    .cam_clk_in(cam_clk_in),
    .vsync_in(vsync_in),
    .href_in(href_in),
    .pixel_in(pixel_in),
    //output framed info from camera for processing:
    .pixel_out(cam_pixel),
    .pixel_valid_out(valid_pixel),
    .frame_done_out(frame_done));

  //Rotates Image to render correctly (pi/2 CCW rotate):
  rotate rotate_m (
    .cam_clk_in(cam_clk_in),
    .valid_pixel_in(valid_pixel),
    .pixel_in(cam_pixel),
    .valid_pixel_out(valid_pixel_rotate),
    .pixel_out(pixel_rotate),
    .frame_done_in(frame_done),
    .pixel_addr_in(pixel_addr_in));

  linebuffer lineb_m
    ( .clk(clk)
    , .rst(sys_rst)
    , .axiiv(valid_pixel_rotate)
    , .axiid(pixel_rotate)
    , .axiov(linebuf_valid)
    , .axiod(linebuf_pixel_out)
    );

endmodule
`default_nettype wire
