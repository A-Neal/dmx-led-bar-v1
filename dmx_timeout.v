// Module that outputs high when a DMX signal is detected, by listening for
// a mark-after-break detection, and outputs low if more than one second
// elapses since the last detection. 
// The purpose is to disable PWM output when a DMX signal is not present.

module dmx_timeout(
	input		clk,
	input		rst,
	output reg	out
	);
	localparam ONE_SECOND = 24'd12000000; // 12 million clock cycles = 1s
	reg [23:0] counter;
	always @(posedge clk) begin
		if(rst) begin
			counter <= 24'd0;
			out <= 1'b1;
		end else if(counter <= ONE_SECOND) begin
			counter <= counter + 1;
			out <= 1'b1;
		end else begin
			out <= 1'b0;
		end
	end
endmodule

