`include "processing_element_ws.sv"

module systolic_array_core #( // Weight Stationary
	IP_WIDTH = 8;
	WT_WIDTH = 8;
	PS_WIDTH = 32;
  GRID_DIM = 8;
  NUM_PES = GRID_DIM*GRID_DIM; // Number of PEs in the systolic array
)( 
	input clk,
	input rst,
	input load_wgt,
	input load_ip,
	input [IP_WIDTH-1:0] ip_act [GRID_DIM-1:0], //input activation
	input [WT_WIDTH-1:0] ip_wgt [NUM_PES-1:0], //input weight
  input [PS_WIDTH-1:0] op_partsum [GRID_DIM-1:0], // partial sum output from the last PE
	output [IP_WIDTH-1:0] ip_fwd // input from the last PE
);
	// Wires for chaining activations (ip_fwd output of PE[i] to ip_act input of PE[i-1])
  wire [IP_WIDTH-1:0] act_fwd_chain [NUM_PES-1:0];
  // Wires for chaining partial sums (op_partsum output of PE[i] to ip_partsum input of PE[i-1])
  wire [IP_WIDTH+WT_WIDTH-1:0] partsum_chain [NUM_PES-1:0];

	genvar i; //Row index of grid
  generate
    for (i = 0; i<GRID_DIM; i = i+1) begin : systolic_pes
      genvar j; //Column index of grid
      generate
        for (j = 0; j<GRID_DIM; j = j+1) begin : systolic_pes
          processing_element_ws #(
                .IP_WIDTH(IP_WIDTH),
                .WT_WIDTH(WT_WIDTH),
                .PS_WIDTH(PS_WIDTH)
            ) mac_pe (
                .clk(clk),
                .rst(rst),
                .load_wgt(GRID_DIM*i+j),
                .ip_partsum((i == 0) ? {PS_WIDTH{1'b0}} : partsum_chain[GRID_DIM*(i-1)+j]), // previous PE
                .ip_act((j == 0) ? ip_act : act_fwd_chain[i+GRID_DIM*(j-1)]), // transpose matrix for easier indexing later
                .ip_wgt(ip_wgt),
                .ip_fwd(act_fwd_chain[i+GRID_DIM*(j)]),                // next PE
                .op_partsum(partsum_chain[GRID_DIM*(i)+j])             // next PE
            ); 
        end
      endgenerate
    end
  endgenerate

	// Connect the outputs of the last PE (mac_pe[NUM_PES-1]) to the module outputs
	assign op_partsum = partsum_chain[NUM_PES-1:NUM_PES-GRID_DIM];
	assign ip_fwd = act_fwd_chain[NUM_PES-1:NUM_PES-GRID_DIM];

endmodule