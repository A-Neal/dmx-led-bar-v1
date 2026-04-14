// An intermediate register in which to hold a specific received byte until
// the entire frame has been checked for errors, and includes logic to ensure
// that the stored byte will not be shifted out if (1) there is an error, (2)
// the first byte in the frame isn't 0x00, or (3) the frame didn't include the
// addressed byte.

module pwm_pre_reg(
	input		clk,
	input		shift_in,
	input		shift_out_trig,
	input [7:0]	data_in,
	input		error,
	input		b0not0,
	input		reset,
	output [7:0]	data_out,
	output		shift_out
	);
	localparam BYTE_NOT_RECEIVED	= 1'b0;
	localparam BYTE_RECEIVED	= 1'b1;
	reg state;
	reg [7:0] data;
	reg shift_in_ff;
	reg reset_ff;
	always @(posedge clk) begin
		shift_in_ff <= shift_in;
		reset_ff <= reset;
	end
	// State transistion logic
	wire trig;
	assign trig = ( shift_in_ff | reset_ff );
	reg trig_dly;
	always @( posedge clk ) begin
		trig_dly <= trig;
		if(trig && !trig_dly) begin
			if(reset_ff) begin
				state <= BYTE_NOT_RECEIVED;
			end else if(shift_in_ff) begin
				state <= BYTE_RECEIVED;
				data <= data_in;
			end
		end
	end
	assign shift_out = ( shift_out_trig && !error && !b0not0 && (state == BYTE_RECEIVED) );
	assign data_out = data;
endmodule

