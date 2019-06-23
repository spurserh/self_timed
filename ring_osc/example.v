module top (
	input  clk,
	output LED1,
	output LED2,
	output LED3,
	output LED4,
	output LED5,
	input arduino7,
	output auxOut
);


// ring oscillator - 213Mhz!
wire chain_in, chain_out;

wire buffers_out;
assign chain_out = buffers_out;
//wire enable = 1; // arduino7
//assign chain_in = enable ? !chain_out : 0;
assign chain_in = !chain_out;

SB_LUT4 #(
	.LUT_INIT(16'd2)
) buffers (
	.O(buffers_out),
	.I0(chain_in),
	.I1(1'b0),
	.I2(1'b0),
	.I3(1'b0)
);

reg [27:0] counter = 0;
always @(posedge chain_out) begin
	counter <= counter + 1;
end

assign LED1 = counter[27];

assign auxOut = counter[4];

endmodule

