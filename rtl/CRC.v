`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/22/2026 12:57:57 PM
// Design Name: 
// Module Name: CRC
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


module CRC(
input Data,Active,Clk,Rst,
output reg Crc,
output reg Valid
    );
    integer i ;
    localparam SEED = 8'hD8;
    reg [7:0]Q_next,Q_reg;
    wire done,clear_n;
    counter #(.n(4)) C1 (
    .clk(Clk),
    .start(Valid),    
    .done(done),
    .clear(Active)
    );
    
    always @(posedge Clk, negedge Rst)
    begin
        if (!Rst)
            Q_reg <= SEED;
        else
            Q_reg <= Q_next;
    end
    
    always @ (*)
    begin
    Q_next = Q_reg;
    
    if( Active)
        begin
            Q_next[7] = Data ^ Q_reg[0];
            Q_next[6]= Q_reg[7] ^ Q_next[7];
            Q_next[5] = Q_reg[6];
            Q_next[4] = Q_reg[5];
            Q_next[3] = Q_reg[4];
            Q_next[2]= Q_reg[3] ^ Q_next[7];
            Q_next[1] = Q_reg[2];
            Q_next[0] = Q_reg[1];
        end
    else
        begin
            if(!done)
                begin
                     for (i=0 ;i<7 ; i= i+1 )begin
                        Q_next[i]=Q_reg[i+1];
                     end     
                end
            else 
                begin
                    Q_next = SEED;
                end
        end
    end
    always @(posedge Clk or negedge Rst) begin
            if (!Rst)
                Crc <= 1'b0;
            else
                Crc <= Q_reg[0];
        end
        
    always @(posedge Clk or negedge Active) begin
                    if (!Active)
                        Valid <= 1'b1;
                    else
                        Valid <= 1'b0;
                end
endmodule
