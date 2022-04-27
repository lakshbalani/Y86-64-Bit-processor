`include "fetch.v"
`include "decode.v"
`include "execute.v"
`include "memory.v"
`include "write_back.v"
`include "pc_update.v"

module y86 ( clk );

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


input clk ;


wire signed [63:0] PC=64'b0;
wire imem_error;
wire [71:0] __align;
wire [7:0] __split;
wire [3:0] icode;
wire [3:0] ifun;
wire nr;
wire nc;
wire [3:0] rA;
wire [3:0] rB;

wire [3:0] dstE;
wire [3:0] dstM;
wire [3:0] srcA;
wire [3:0] srcB;
wire cnd;

wire signed [63:0] valA;
wire signed [63:0] valB;
wire signed [63:0] valC;
wire signed [63:0] valE;
wire signed [63:0] valM;
wire signed [63:0] valP;

wire mem_r;
wire mem_w;
wire signed [63:0] mem_add;
wire signed [63:0] mem_data;
wire dmem_error;




Instr_memory ins_m(.PC(PC),.__split(__split),.__align(__align),.imem_error(imem_error));

split sp(.ibyte(__split), .icode(icode), .ifun(ifun));

assign nr = ((icode == IRRMOVQ) || (icode == IIRMOVQ) || (icode == IRMMOVQ) || (icode == IMRMOVQ) || (icode == IOPQ) || (icode == IPUSHQ) || (icode == IPOPQ)) ? 1'b1 : 1'b0 ;
assign nc = ((icode == IIRMOVQ) || (icode == IRMMOVQ) || (icode == IMRMOVQ) || (icode == IJXX) || (icode == ICALL) ) ? 1'b1 : 1'b0 ;

align al(.ibytes(__align), .need_regids(nr), .rA(rA), .rB(rB), .valC(valC));

PC_increment inc_pc(.PC(PC), .need_regids(nr), .need_valC(nc), .valP(valP));

decode dec(.dstE(dstE), .dstM(dstM), .srcA(srcA), .srcB(srcB), .icode(icode), .rA(rA), .rB(rB), .Cnd(cnd));

write_back wr_ba(.valA(valA), .valB(valB), .valM(valM), .valE(valE), .dstE(dstE), .dstM(dstM), .srcA(srcA), .srcB(srcB) );

execute exe(.icode(icode), .ifun(ifun), .valA(valA), .valB(valB), .valC(valC), .Cnd(cnd), .valE(valE));

mem_1 m1(.mem_r(mem_r),.mem_w(mem_w),.mem_add(mem_add),.mem_data(mem_data),.icode(icode),.valE(valE),.valA(valA),.valP(valP));
mem_2 m2( .valM(valM),.dmem_error(dmem_error),.mem_r(mem_r),.mem_w(mem_w),.mem_add(mem_add),.mem_data(mem_data));

pc_update upPC(.PC(PC), .icode(icode), .Cnd(cnd), .valC(valC), .valM(valM), .valP(valP));


endmodule