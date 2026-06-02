module relu #(
	IP_WIDTH = 8;
)(
	input [IP_WIDTH-1:0] ip 
	output [IP_WIDTH-1:0] op
)
	assign (ip[IP_WIDTH-1]==1)? 0 : ip; //if sign bit 1, output 0, else output = input
endmodule