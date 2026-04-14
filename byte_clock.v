// Byte clock for the DMX decoder

module byte_clock(
	input		clk,
	input		rst,
	input		dmx,
	output		debug,
	output	reg	bit_clk,
	output		slot_end
	);
	localparam IDLE	   =	2'b00;
	localparam PRIMED  =	2'b01;
	localparam TICKING =	2'b10;
	localparam RESET   =	2'b11;

	localparam DLY_CYCLES = 23; // 2 microseconds minus 1 cycle

	reg [1:0] state;
	reg reset_pulse;
	reg [4:0] clk_counter;
	reg [3:0] bit_counter;

	/*
	initial begin
		state <= IDLE;
		clk_counter <= 5'd0;
		bit_counter <= 4'd0;
		bit_clk <= 1'b0;
		reset_pulse <= 1'b0;
	end
	*/
	// State transistion logic
	//wire state_trig;
	//assign state_trig = (clk | rst);
	always @(posedge clk) begin
		if(rst) begin
			state <= IDLE;
		end else begin
			case(state)
				IDLE: begin
					if(dmx) state <= PRIMED;
					clk_counter <= 5'd0;
					bit_clk <= 1'b0;
					reset_pulse <= 1'b0;
				end
				PRIMED: begin
					if(!dmx) state <= TICKING;
				end
				TICKING: begin
					if(bit_counter == 4'd11) begin
						state <= RESET;
						bit_clk <= 1'b0;
					end else begin
						if(clk_counter >= DLY_CYCLES) begin
							bit_clk <= ~bit_clk;
							clk_counter <= 5'd0;
						end else begin
							clk_counter <= clk_counter + 1;
						end
					end
				end
				RESET: begin
					if(!bit_counter) begin
						state <= IDLE;
						reset_pulse <= 1'b0;
					end else begin
						reset_pulse <= 1'b1;
					end
				end
				default: state <= IDLE;
			endcase
		end
	end
	/*
	// clk_counter logic
	always @(posedge clk) begin
		case(state)
			IDLE: begin
				clk_counter <= 5'd0;
				bit_clk <= 1'b0;
				reset_pulse <= 1'b0;
			end
			TICKING: begin
				if(clk_counter >= DLY_CYCLES) begin
					bit_clk <= ~bit_clk;
					clk_counter <= 5'd0;
				end else begin
					clk_counter <= clk_counter + 1;
				end
			end
			RESET: begin
				reset_pulse <= 1'b1;
			end
		endcase
	end
	*/
	// bit_counter logic
	wire trig;
	assign trig =  (bit_clk | reset_pulse);
	reg trig_dly;
	always @(posedge clk) begin
		trig_dly <= trig;
		if(trig && !trig_dly) begin
			case(state)
				IDLE: bit_counter <= 4'd0;
				TICKING: begin
					bit_counter <= bit_counter + 1;
				end
				RESET: bit_counter <= 4'd0;
			endcase
		end
	end
	//assign debug = ~(state ^ TICKING);
	assign debug = (state == TICKING);
	wire reset_out;
	assign slot_end = reset_out;
	us_pulse pulse(
		.in(reset_pulse),
		.clk(clk),
		.out(reset_out)
		);
endmodule

