`timescale 1ns / 1ps


module u_xmit(
    input sys_clk, // The master clock for this module
    input sys_rst_I, // Synchronous reset.
    output uart_XMIT_dataH, // Outgoing serial line
    input xmitH, // Signal1 to transmit
    input [7:0] xmit_dataH, // Byte to transmit
    output reg xmit_doneH // High when transmit line is idle.
    );
parameter CLOCK_DIVIDE = 1302; // clock rate (50Mhz) / (baud rate (9600) * 4)           /* actually 1302.083333333333333333 */

parameter TX_IDLE = 0;
parameter TX_SENDING = 1;
parameter TX_DELAY_RESTART = 2;


reg [10:0] tx_clk_divider = CLOCK_DIVIDE;

reg tx_out = 1'b1;
reg [1:0] tx_state = TX_IDLE;
reg [5:0] tx_countdown;
reg [3:0] tx_bits_remaining;
reg [7:0] tx_data;

    initial
    begin
    xmit_doneH = 1'b0;
    end

assign uart_XMIT_dataH = tx_out;

always @(posedge sys_clk) begin
	if (sys_rst_I) begin
		tx_state = TX_IDLE;
	end

	// The clk_divider counter counts down from
	// the CLOCK_DIVIDE constant. Whenever it
	// reaches 0, 1/16 of the bit period has elapsed.
   // Countdown timers for the transmitting
	// state machine is decremented.
	tx_clk_divider = tx_clk_divider - 1;
	if (!tx_clk_divider) begin
		tx_clk_divider = CLOCK_DIVIDE;
		tx_countdown = tx_countdown - 1;
	end


//      transmitter state machine
    case (tx_state)
		TX_IDLE: begin
			if (xmitH) begin
				// If the transmit flag is raised in the idle
				// state, start transmitting the current content
				// of the xmit_dataH input.
				tx_data = xmit_dataH;
				// Send the initial, low pulse of 1 bit period
				// to signal the start, followed by the data
				tx_clk_divider = CLOCK_DIVIDE;
				tx_countdown = 4;
				tx_out = 0;
				tx_bits_remaining = 8;
				tx_state = TX_SENDING;
			end
		end
		TX_SENDING: begin
			if (!tx_countdown) begin
				if (tx_bits_remaining) begin
					tx_bits_remaining = tx_bits_remaining - 1;
					tx_out = tx_data[0];
					tx_data = {1'b0, tx_data[7:1]};
					tx_countdown = 4;
					tx_state = TX_SENDING;
				end else begin
					// Set delay to send out 2 stop bits.
					tx_out = 1;
					tx_countdown = 4;
					tx_state = TX_DELAY_RESTART;
				end
			end
		end
		TX_DELAY_RESTART: begin
			// Wait until tx_countdown reaches the end before
			// we send another transmission. This covers the
			// "stop bit" delay.
			tx_state = tx_countdown ? TX_DELAY_RESTART : TX_IDLE;
			
  
           
            if((tx_countdown == 1) && TX_DELAY_RESTART)
                xmit_doneH = 1'b1;
            else
                xmit_doneH = 1'b0;
		end
	endcase
end

endmodule
