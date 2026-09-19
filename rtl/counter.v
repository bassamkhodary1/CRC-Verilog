`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/22/2026 01:46:34 PM
// Design Name: 
// Module Name: counter
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module counter
#(parameter n=4)
(
input clk,clear,start,
output done
    );
    localparam [n-1:0]Const= 7;
    reg [n-1:0]Q_next,Q_reg;
    always @ (posedge clk, posedge clear)
    begin
        if (clear)
            Q_reg <= Const;
        else
            Q_reg <= Q_next;
    end
    
    always @ (*)
    begin
       if (start)
        Q_next=Q_reg +1'b1;
        else Q_next = Q_reg;
    end
    assign done = &Q_reg;
endmodule
