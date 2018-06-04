`timescale 1ns / 1ps


module uart(
    input sys_clk,
    input uart_REC_dataH,
    output uart_XMIT_dataH
    );
    
    reg xmitH = 1'b0;
    reg sys_rst_I = 1'b0;
    
    wire xmit_doneH;
    wire [7:0] rec_dataH;
    wire rec_readyH;
    wire is_receiving;
    wire recv_error;

    parameter PULSE_WIDTH = 5200;

    reg [12:0] count = 0;

    wire count_rst = sys_rst_I | (count == PULSE_WIDTH);

    always @ (posedge rec_readyH, posedge count_rst) begin
            if (count_rst) begin
                    xmitH <= 1'b0;
            end else begin
                    xmitH <= 1'b1;
            end
    end

    always @ (posedge sys_clk, posedge count_rst) begin
            if(count_rst) begin
                    count <= 0;
            end else begin
                    if(xmitH) begin
                            count <= count + 1'b1;
                    end
            end
        end
                   
    u_rec inst1(
        sys_clk, 
        sys_rst_I,
        uart_REC_dataH,
        rec_readyH, 
        rec_dataH,
        is_receiving, 
        recv_error
        );

    u_xmit inst2(
        sys_clk, 
        sys_rst_I,
        uart_XMIT_dataH,
        xmitH,
        rec_dataH,
        xmit_doneH 
        );
    
    
endmodule
