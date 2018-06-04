`timescale 1ns / 1ps



module u_rec(
    input sys_clk, // The master clock for this module
    input sys_rst_I, // Synchronous reset.
    input uart_REC_dataH, // Incoming serial line
    output rec_readyH, // Indicated that a byte has been received.
    output [7:0] rec_dataH, // Byte received
    output is_receiving, // Low when receive line is idle.
    output recv_error
    );
    
    parameter CLOCK_DIVIDE =  1302; // clock rate (50Mhz) / (baud rate (9600) * 4)
    
    // States for the receiving state machine.
    // These are just constants, not parameters to override.
    parameter RX_IDLE = 0;
    parameter RX_CHECK_START = 1;
    parameter RX_READ_BITS = 2;
    parameter RX_CHECK_STOP = 3;
    parameter RX_DELAY_RESTART = 4;
    parameter RX_ERROR = 5;
    parameter RX_RECEIVED = 6;
    
    
    reg [10:0] rx_clk_divider = CLOCK_DIVIDE;
    
    
    reg [2:0] recv_state = RX_IDLE;
    reg [5:0] rx_countdown;
    reg [3:0] rx_bits_remaining;
    reg [7:0] rx_data = 8'b00000000;
    
   
    assign rec_readyH = recv_state == RX_RECEIVED;
    assign recv_error = recv_state == RX_ERROR;
    assign is_receiving = recv_state != RX_IDLE;
    assign rec_dataH = rx_data;
    
    
    always @(posedge sys_clk) begin
        if (sys_rst_I) begin
            recv_state = RX_IDLE;
        end
    
        // The clk_divider counter counts down from
        // the CLOCK_DIVIDE constant. Whenever it
        // reaches 0, 1/16 of the bit period has elapsed.
       // Countdown timers for the receiving and transmitting
        // state machines are decremented.
        rx_clk_divider = rx_clk_divider - 1;
        if (!rx_clk_divider) begin
            rx_clk_divider = CLOCK_DIVIDE;
            rx_countdown = rx_countdown - 1;
        end
        
        
        // Receive state machine
        case (recv_state)
            RX_IDLE: begin
                // A low pulse on the receive line indicates the
                // start of data.
                if (!uart_REC_dataH) begin
                    // Wait half the period - should resume in the
                    // middle of this first pulse.
                    rx_clk_divider = CLOCK_DIVIDE;
                    rx_countdown = 2;
                    recv_state = RX_CHECK_START;
                end
            end
            RX_CHECK_START: begin
                if (!rx_countdown) begin
                    // Check the pulse is still there
                    if (!uart_REC_dataH) begin
                        // Pulse still there - good
                        // Wait the bit period to resume half-way
                        // through the first bit.
                        rx_countdown = 4;
                        rx_bits_remaining = 8;
                        recv_state = RX_READ_BITS;
                    end else begin
                        // Pulse lasted less than half the period -
                        // not a valid transmission.
                        recv_state = RX_ERROR;
                    end
                end
            end
            RX_READ_BITS: begin
                if (!rx_countdown) begin
                    // Should be half-way through a bit pulse here.
                    // Read this bit in, wait for the next if we
                    // have more to get.
                    rx_data = {uart_REC_dataH, rx_data[7:1]};
                    rx_countdown = 4;
                    rx_bits_remaining = rx_bits_remaining - 1;
                    recv_state = rx_bits_remaining ? RX_READ_BITS : RX_CHECK_STOP;
                end
            end
            RX_CHECK_STOP: begin
                if (!rx_countdown) begin
                    // Should resume half-way through the stop bit
                    // This should be high - if not, reject the
                    // transmission and signal an error.
                    recv_state = uart_REC_dataH ? RX_RECEIVED : RX_ERROR;
                end
            end
            RX_DELAY_RESTART: begin
                // Waits a set number of cycles before accepting
                // another transmission.
                recv_state = rx_countdown ? RX_DELAY_RESTART : RX_IDLE;
            end
            RX_ERROR: begin
                // There was an error receiving.
                // Raises the recv_error flag for one clock
                // cycle while in this state and then waits
                // 2 bit periods before accepting another
                // transmission.
                rx_countdown = 8;
                recv_state = RX_DELAY_RESTART;
            end
            RX_RECEIVED: begin
                // Successfully received a byte.
                // Raises the received flag for one clock
                // cycle while in this state.
                recv_state = RX_IDLE;
            end
        endcase
  end  
endmodule
