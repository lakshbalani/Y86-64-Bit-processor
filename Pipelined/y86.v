`include "fetch.v"
`include "decode.v"
`include "execute.v"
`include "memory.v"
`include "write_back.v"

module pipereg(out, in, stall, Bubbleval, clock);

	input stall, clock;	
  parameter w=8;
	input [w-1:0] in;	
	input [w-1:0] Bubbleval;
	output reg [w-1:0] out;
	initial begin 
	    assign out = Bubbleval;
	end
	
	always @(posedge clock) 
	begin
	    if (!stall)
	        assign out = in;
	end

endmodule

module pipereg2(out, in, stall,Bubble, Bubbleval, clock);

  parameter w=8;
	output reg [w-1:0] out;
	input [w-1:0] in;
	input stall,Bubble;
	input [w-1:0] Bubbleval;
	input clock;

	initial begin 
	     assign out=Bubbleval;
	end
	
	always @(posedge clock) begin
	    if (!stall && !Bubble)
	        assign out = in;
	    else if (!stall && Bubble)
	        assign out = Bubbleval;
	end
endmodule


module y86 ( clk, W_stat );

  // These are the instructions
      parameter IHALT = 4'h0;
      parameter INOP = 4'h1;
      parameter IRRMOVQ = 4'h2;
      parameter IIRMOVQ = 4'h3;
      parameter IRMMOVQ = 4'h4;
      parameter IMRMOVQ = 4'h5;
      parameter IOPQ = 4'h6;
      parameter IJXX = 4'h7;
      parameter ICALL = 4'h8;
      parameter IRET = 4'h9;
      parameter IPUSHQ = 4'hA;
      parameter IPOPQ = 4'hB;
  // These are some Status conditions
    	parameter BUB = 3'h0;
    	parameter AOK = 3'h1;
    	parameter HLT = 3'h2;
    	parameter ADR = 3'h3;
    	parameter INS = 3'h4;


input clk ;
output [2:0] W_stat;


wire [63:0] f_predPC, F_predPC, f_pc;
wire imem_error;
wire [ 2:0] f_stat;
wire [71:0] __align;
wire [7:0] __split;
wire [ 3:0] f_icode, f_ifun;
wire [ 3:0] f_rA, f_rB;
wire [63:0] f_valC;
wire [63:0] f_valP;
wire need_regids, need_valC, instr_valid;
wire F_stall, F_BUBble, F_reset;
wire nr;
wire nc;


wire [ 2:0] D_stat;
wire [63:0] D_pc;
wire [ 3:0] D_icode;
wire [ 3:0] D_ifun;
wire [ 3:0] D_rA, D_rB;
wire [63:0] D_valC;
wire [63:0] D_valP;
wire [63:0] d_valA;
wire [63:0] d_valB;
wire [63:0] d_rvalA, d_rvalB;
wire [3:0] d_dstE;
wire [3:0] d_dstM;
wire [3:0] d_srcA;
wire [3:0] d_srcB;
wire d_cnd;
wire D_stall, D_BUBble;

wire [ 2:0] E_stat;
wire [63:0] E_pc;
wire [ 3:0] E_icode, E_ifun;
wire [63:0] E_valC, E_valA, E_valB;
wire [ 3:0] E_dstE, E_dstM, E_srcA, E_srcB;
wire [63:0] ALUA, ALUB;
wire set_CC;
wire [ 2:0] CC;
wire [ 2:0] new_CC;
wire [ 3:0] ALUfun;
wire [63:0] e_valE, e_valA;
wire [ 3:0] e_dstE;
wire e_Cnd;
wire E_stall, E_BUBble;


wire mem_r;
wire mem_w;
wire [ 2:0] M_stat;
wire [63:0] M_pc;
wire [ 3:0] M_icode, M_ifun;
wire M_Cnd;
wire [63:0] m_valM;
wire [63:0] M_valE, M_valA,M_valP;
wire [ 3:0] M_dstE, M_dstM;
wire [ 2:0] m_stat;
wire [63:0] mem_add;
wire [63:0] mem_data;
wire dmem_error;

wire [ 2:0] W_stat;
wire [63:0] W_pc;
wire [ 3:0] W_icode;
wire signed [63:0] W_valA;
wire signed [63:0] W_valB;
wire signed [63:0] W_valC;
wire signed [63:0] W_valE;
wire signed [63:0] W_valM;
wire signed [63:0] W_valP;
wire [3:0] W_srcA,W_srcB;
wire [ 3:0] W_dstE, W_dstM;
wire [ 3:0] w_dstE, w_dstM;
wire W_stall, W_BUBble, resetting;

      assign Stat =((W_stat == BUB) ? AOK : W_stat);
    	assign F_bubble = 0;
    	assign F_stall =(((E_icode == IMRMOVQ | E_icode == IPOPQ) & (E_dstM == d_srcA | E_dstM == d_srcB)) | (IRET == D_icode | IRET == E_icode | IRET == M_icode));
    	assign D_stall =((E_icode == IMRMOVQ | E_icode == IPOPQ) & (E_dstM == d_srcA | E_dstM == d_srcB));
    	assign D_bubble =(((E_icode == IJXX) & ~e_Cnd) | (~((E_icode == IMRMOVQ | E_icode ==IPOPQ) & (E_dstM == d_srcA | E_dstM == d_srcB)) & (IRET ==D_icode | IRET == E_icode | IRET == M_icode)));
    	assign E_stall =0;
    	assign E_bubble =(((E_icode == IJXX) & ~e_Cnd) | ((E_icode == IMRMOVQ | E_icode == IPOPQ) & (E_dstM == d_srcA | E_dstM == d_srcB)));
    	assign M_stall =0;
    	assign M_bubble =((m_stat == ADR | m_stat == INS | m_stat == HLT) | (W_stat == ADR | W_stat == INS | W_stat == HLT));
    	assign W_stall =(W_stat == ADR | W_stat == INS | W_stat == HLT);
    	assign W_bubble =0;


pipereg #(64) F_predPC_reg(F_predPC, f_predPC, F_stall, 64'b0, clock);

// D stage
    	pipereg #(3) D_stat_reg(D_stat, f_stat, D_stall,   BUB, clock);
    	pipereg #(64) D_pc_reg(D_pc, f_pc, D_stall,   64'b0, clock);
	    pipereg2 #(4) D_icode_reg(D_icode, f_icode, D_stall, D_BUBble,  INOP, clock);
    	//pipereg #(4) D_icode_reg(D_icode, f_icode, D_stall,   INOP, clock);     
    	pipereg #(4) D_ifun_reg(D_ifun, f_ifun, D_stall, 4'h0, clock);
    	pipereg #(4) D_rA_reg(D_rA, f_rA, D_stall, 4'hF, clock);
    	pipereg #(4) D_rB_reg(D_rB, f_rB, D_stall, 4'hF, clock);
    	pipereg #(64) D_valC_reg(D_valC, f_valC, D_stall, 64'b0, clock);
    	pipereg #(64) D_valP_reg(D_valP, f_valP, D_stall, 64'b0, clock);
    
// E stage
    	pipereg #(3) E_stat_reg(E_stat, D_stat, E_stall,  BUB, clock);
    	pipereg #(64) E_pc_reg(E_pc, D_pc, E_stall,  64'b0, clock);
	    pipereg #(4) E_icode_reg(E_icode, D_icode, E_stall,  INOP, clock);
    	pipereg #(4) E_ifun_reg(E_ifun, D_ifun, E_stall,  4'h0, clock);
    	pipereg #(64) E_valC_reg(E_valC, D_valC, E_stall,  64'b0, clock);
    	pipereg #(64) E_valA_reg(E_valA, d_valA, E_stall,  64'b0, clock);
    	pipereg #(64) E_valB_reg(E_valB, d_valB, E_stall,  64'b0, clock);
    	pipereg #(4) E_dstE_reg(E_dstE, d_dstE, E_stall,  4'hF, clock);
    	pipereg #(4) E_dstM_reg(E_dstM, d_dstM, E_stall,  4'hF, clock);
    	pipereg #(4) E_srcA_reg(E_srcA, d_srcA, E_stall,  4'hF, clock);
    	pipereg #(4) E_srcB_reg(E_srcB, d_srcB, E_stall,  4'hF, clock);

// M stage
    	pipereg #(3) M_stat_reg(M_stat, E_stat, M_stall,  BUB, clock);
    	pipereg #(64) M_pc_reg(M_pc, E_pc, M_stall,  64'b0, clock);
    	pipereg #(4) M_icode_reg(M_icode, E_icode, M_stall,  INOP, clock);
    	pipereg #(4) M_ifun_reg(M_ifun, E_ifun, M_stall,  4'h0, clock);
    	pipereg #(1) M_Cnd_reg(M_Cnd, e_Cnd, M_stall,  1'b0, clock);
    	pipereg #(64) M_valE_reg(M_valE, e_valE, M_stall,  64'b0, clock);
    	pipereg #(64) M_valA_reg(M_valA, e_valA, M_stall,  64'b0, clock);
    	pipereg #(4) M_dstE_reg(M_dstE, e_dstE, M_stall,  4'hF, clock);
    	pipereg #(4) M_dstM_reg(M_dstM, E_dstM, M_stall,  4'hF, clock);
    
// W stage
    	pipereg #(3) W_stat_reg(W_stat, m_stat, W_stall,  BUB, clock);
    	pipereg #(64) W_pc_reg(W_pc, M_pc, W_stall,  64'b0, clock);
    	pipereg #(4) W_icode_reg(W_icode, M_icode, W_stall,  INOP, clock);
    	pipereg #(64) W_valE_reg(W_valE, M_valE, W_stall,  64'b0, clock);
    	pipereg #(64) W_valM_reg(W_valM, m_valM, W_stall,  64'b0, clock);
    	pipereg #(4) W_dstE_reg(W_dstE, M_dstE, W_stall,  4'hF, clock);
    	pipereg #(4) W_dstM_reg(W_dstM, M_dstM, W_stall,  4'hF, clock);


Instr_memory ins_m(.PC(f_pc),.__split(__split),.__align(__align),.imem_error(imem_error));

split sp(.ibyte(__split), .icode(f_icode), .ifun(f_ifun));

assign nr = ((f_icode == IRRMOVQ) || (f_icode == IIRMOVQ) || (f_icode == IRMMOVQ) || (f_icode == IMRMOVQ) || (f_icode == IOPQ) || (f_icode == IPUSHQ) || (f_icode == IPOPQ)) ? 1'b1 : 1'b0 ;
assign nc = ((f_icode == IIRMOVQ) || (f_icode == IRMMOVQ) || (f_icode == IMRMOVQ) || (f_icode == IJXX) || (f_icode == ICALL) ) ? 1'b1 : 1'b0 ;

align al(.ibytes(__align), .need_regids(nr), .rA(f_rA), .rB(f_rB), .valC(f_valC));

PC_increment inc_pc(.PC(f_pc), .need_regids(nr), .need_valC(nc), .valP(f_valP));

decode dec(.dstE(d_dstE), .dstM(d_dstM), .srcA(d_srcA), .srcB(d_srcB), .icode(D_icode), .rA(D_rA), .rB(D_rB), .Cnd(d_cnd));

execute exe(.icode(E_icode), .ifun(E_ifun), .valA(E_valA), .valB(E_valB), .valC(E_valC), .Cnd(e_cnd), .valE(e_valE));

mem_1 m1(.mem_r(mem_r),.mem_w(mem_w),.mem_add(mem_add),.mem_data(mem_data),.icode(M_icode),.valE(M_valE),.valA(M_valA),.valP(M_valP));
mem_2 m2( .valM(m_valM),.dmem_error(dmem_error),.mem_r(mem_r),.mem_w(mem_w),.mem_add(mem_add),.mem_data(mem_data));

write_back wr_ba(.valA(W_valA), .valB(W_valB), .valM(W_valM), .valE(W_valE), .dstE(W_dstE), .dstM(W_dstM), .srcA(W_srcA), .srcB(W_srcB) );


endmodule