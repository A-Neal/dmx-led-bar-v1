// Module to quantize an asynchronous signal to the master clock

module async_synchronizer(
	input		clk,
	input		async,
	output	reg	sync
	);
	always @(posedge clk) begin
		sync <= async;
	end
endmodule

