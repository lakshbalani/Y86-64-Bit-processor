module Instr_memory(
    PC,
    __split,
    __align,
    imem_error
);
   initial begin
       $readmemh("./instructions.mem",instr_mem);
   end

   input [63:0] PC;
   reg [7:0] instr_mem[2047:0];
   output reg[71:0] __align;
   output reg[7:0] __split;
   output reg imem_error;


   always @(PC)
   begin
       imem_error <= (PC < 64'd0 || PC > 64'd9824) ? 1'b1:1'b0;
        __split <= instr_mem[PC];
        __align[71:64] <= instr_mem[PC+1];
        __align[63:56] <= instr_mem[PC+2];
        __align[55:48] <= instr_mem[PC+3];
        __align[47:40] <= instr_mem[PC+4];
        __align[39:32] <= instr_mem[PC+5];
        __align[31:24] <= instr_mem[PC+6];
        __align[23:16] <= instr_mem[PC+7];
        __align[15:8]  <= instr_mem[PC+8];
        __align[ 7:0]  <= instr_mem[PC+9];
   end  

endmodule

module split(ibyte, icode, ifun);
	input [7:0] ibyte;
	output [3:0] icode, ifun;
	assign ifun = ibyte[3:0];	
	assign icode = ibyte[7:4];	

endmodule

module align(ibytes, need_regids, rA, rB, valC);
	input need_regids;	
	input [71:0] ibytes;
	output [ 3:0] rA, rB;
	output [63:0] valC;
	assign rA = ibytes[71:68];
	assign rB = ibytes[67:64];
	assign valC = need_regids ? ibytes[63:0] : ibytes[71:8];

endmodule

module PC_increment(PC, need_regids, need_valC, valP);
	input [63:0] PC;
	input need_regids, need_valC;
	output [63:0] valP;
	assign valP = PC + 1 + 8*need_valC + need_regids;
    
endmodule