
module serial_debug_report(
	input		clk,
	input	[7:0]	in,
	output	reg	out
);

localparam BITLENGTH	= 120;

localparam COUNTING	= 1'b0;
localparam NEXTBIT	= 1'b1;

reg state;

reg [15:0] output_buffer;
reg [6:0] bit_timer;

always @(posedge clk) begin
	if(state == COUNTING) begin
		if(bit_timer >= BITLENGTH) begin
			state <= NEXTBIT;
			bit_timer <= 7'd0;
		end
	end else begin
		state <= COUNTING;
	end
end

reg state_dly;
always @(posedge clk) begin
	state_dly <= state;
	if(state == NEXTBIT && state_dly != NEXTBIT) begin
		if(output_buffer == 16'd0) begin
			output_buffer[15:8] <= 8'd254;
			output_buffer[7:0] <= in;
		end else begin
			output_buffer <= output_buffer << 1;
		end
	end
end

always @(posedge clk) begin
	out <= output_buffer[15];
end

endmodule

