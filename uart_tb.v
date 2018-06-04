`timescale 1ns / 1ps



module uart_tb(
    );
    // Common
    reg sys_clk;
    
    // Transmitter 
    wire uart_XMIT_dataH;
    
    // Receiver
    reg uart_REC_dataH;
    
    
    uart DUT(
        .sys_clk(sys_clk),
        .uart_XMIT_dataH(uart_XMIT_dataH),        
        .uart_REC_dataH(uart_REC_dataH)   
        );
        
    initial
        begin
            sys_clk = 0;         
            uart_REC_dataH = 1;
        end
        
    always #5 sys_clk = ~sys_clk;            
    
    initial
    begin
        #104000 uart_REC_dataH = 0;
        #52000 uart_REC_dataH = 1;
        #52000 uart_REC_dataH = 1;
        #52000 uart_REC_dataH = 0;
        #52000 uart_REC_dataH = 0;
        #52000 uart_REC_dataH = 0;
        #52000 uart_REC_dataH = 0;
        #52000 uart_REC_dataH = 1;
        #52000 uart_REC_dataH = 0;
        #52000 uart_REC_dataH = 1; 
        
        #200000 uart_REC_dataH = 0;
        #52000 uart_REC_dataH = 0;
        #52000 uart_REC_dataH = 0;
        #52000 uart_REC_dataH = 1;
        #52000 uart_REC_dataH = 0;
        #52000 uart_REC_dataH = 0;
        #52000 uart_REC_dataH = 0;
        #52000 uart_REC_dataH = 1;
        #52000 uart_REC_dataH = 0;
        #52000 uart_REC_dataH = 1;
        
        
        #200000 uart_REC_dataH = 0;
        #52000 uart_REC_dataH = 1;
        #52000 uart_REC_dataH = 0;
        #52000 uart_REC_dataH = 1;
        #52000 uart_REC_dataH = 0;
        #52000 uart_REC_dataH = 0;
        #52000 uart_REC_dataH = 0;
        #52000 uart_REC_dataH = 1;
        #52000 uart_REC_dataH = 0;
        #52000 uart_REC_dataH = 1;
        
        #200000 uart_REC_dataH = 0;
        #52000 uart_REC_dataH = 0;
        #52000 uart_REC_dataH = 1;
        #52000 uart_REC_dataH = 1;
        #52000 uart_REC_dataH = 0;
        #52000 uart_REC_dataH = 0;
        #52000 uart_REC_dataH = 0;
        #52000 uart_REC_dataH = 1;
        #52000 uart_REC_dataH = 0;
        #52000 uart_REC_dataH = 1;
        #5200000 $finish;
    end
    
endmodule
