//Reads from Input BRAM using sliding window address pointers.
//Writes flattened vectors to the Skewing FIFOs.
//Bandwidth constraint: Must output one 8-element vector per clock cycle to keep the array fed.

module im2col #(
  IP_WIDTH = 8;
	WT_WIDTH = 8;
	PS_WIDTH = 32;
  GRID_DIM = 8;
)(
  input clk,
  input rst,
  input start,
  output [IP_WIDTH-1:0] ip_act [GRID_DIM-1:0], //input activation
  output [WT_WIDTH-1:0] ip_wgt [GRID_DIM-1:0], //input weight
  output done
);

endmodule