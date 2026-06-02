module processing_element_ws #( // Weight Stationary
	IP_WIDTH = 8;
	WT_WIDTH = 8;
	PS_WIDTH = 32;
)(
	input clk,
	input rst,
	input load_wgt,
	input [IP_WIDTH+WT_WIDTH-1:0] ip_partsum, //partial sum from above PE
	input [IP_WIDTH-1:0] ip_act, //input activation
	input [WT_WIDTH-1:0] ip_wgt, //input weight
	output [IP_WIDTH-1:0] ip_fwd, //forwarded input to right PE
	output [IP_WIDTH+WT_WIDTH-1:0] op_partsum //partial sum to below PE
)
	reg [WT_WIDTH-1:0] wgt; //weight
	always @(posedge clk) begin
		if(rst) wgt <= 0;
		else begin
			if(load_wgt) wgt <= ip_wgt; // load weights
			else begin
				ip_fwd <= ip_act;
				op_partsum <= ip_partsum + ip_act*wgt;
			end
		end
	end
endmodule