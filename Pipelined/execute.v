`include "../ALU/ALU/alu.v"


module execute(icode, ifun, valA, valB, valC, Cnd, valE);
// Branch condition
	input [3:0] ifun;
  input [3:0] icode;
  input [63:0] valA;
  input [63:0] valB;
  input [63:0] valC;
  output reg [63:0] valE;  
	output reg Cnd;

	// Jump conditions.
	parameter J_YES = 4'h0;
	parameter J_LE = 4'h1;
	parameter J_L = 4'h2;
	parameter J_E = 4'h3;
	parameter J_NE = 4'h4;
	parameter J_GE = 4'h5;
	parameter J_G = 4'h6;

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

  assign ALUA =
  icode == IRRMOVQ ?valA: 
  icode == IOPQ ? valA : 
  icode == IIRMOVQ ? valC:
  icode == IRMMOVQ ? valC: 
  icode == IMRMOVQ ? valC : 
  icode == ICALL ? -8:
  icode == IPUSHQ ? -8 : 
  icode == IRET ? 8:
  icode == IPOPQ ? 8 : 0;

  assign ALUB =
  icode == IRMMOVQ ? valB:
  icode == IMRMOVQ ? valB:
  icode == IOPQ ? valB:
  icode == ICALL ? valB:
  icode == IPUSHQ ? valB:
  icode == IRET ? valB:
  icode == IPOPQ ? valB : 
  icode == IRRMOVQ ? 0:
  icode == IIRMOVQ ? 0 : 0;

  wire [1:0] sel_line;
  assign sel_line =
  icode == IRMMOVQ ? 2'b0:
  icode == IMRMOVQ ? 2'b0:
  icode == IOPQ ? ifun:
  icode == ICALL ? 2'b0:
  icode == IPUSHQ ? 2'b0:
  icode == IRET ? 2'b0:
  icode == IPOPQ ? 2'b0 : 
  icode == IRRMOVQ ? 2'b0:
  icode == IIRMOVQ ? 2'b0 : 0;

  

  wire overflow_flag;
  wire [63:0]ans;
  ALU alu_module (.ans(ans),.overflow(overflow_flag),.sel(sel_line),.a(valA),.b(valB));
	reg ZF,SF,OF;
  
	 
  always@(*) 
  begin
  valE = ans;
  SF=valE[63];
  if(valE== 64'b0) begin
    ZF=1;
  end
  else begin
     ZF=0;
  end

  OF=overflow_flag;	
 

 Cnd =
	(ifun == J_YES) | 
	(ifun == J_LE & ((ZF^OF)|ZF)) | 
	(ifun == J_L & (SF^OF)) | 
	(ifun == J_E & ZF) | 
	(ifun == J_NE & ~ZF) | 
	(ifun == J_GE & (~SF^OF)) | 
	(ifun == J_G & (~SF^OF)&~ZF);
   end

endmodule