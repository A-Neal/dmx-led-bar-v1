// Module to count the DMX slots received in the current frame, since the last
// make-after-break detection

module slot_counter(
	input			clk,
	input			inc,
	input			rst,
	output reg [9:0]	slot_num
	);
	/*
	initial begin
		slot_num <= 10'd0;
	end
	*/
	wire trig;
	assign trig = (inc ^ rst);
	reg trig_dly;
	always @(posedge clk) begin
		trig_dly <= trig;
		if(trig && !trig_dly) begin
			if(rst) begin
				slot_num <= 10'd0;
			end else begin
				slot_num <= slot_num + 1;
			end
		end
	end

endmodule

