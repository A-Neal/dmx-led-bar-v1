
module test(
	input		CLK_12MHz,
	input		DMX_INPUT,
	input	[8:0]	DMX_ADDR,
	output	[5:0]	PWM_OUT,
	output		DEBUG_OUT
);

reg	[23:0]	test;

always @ (posedge CLK_12MHz) begin
	test <= test + 1;
end

assign PWM_OUT[5:0] = test[23:18];

endmodule

