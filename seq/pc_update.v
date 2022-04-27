module pc_update(PC,icode,Cnd,valC,valM,valP);
   
   output reg signed [63:0] PC;

   input [3:0] icode;
   input Cnd;
   input signed [63:0] valC;
   input signed [63:0] valM;
   input signed [63:0] valP;
   
   always @(*) 
   begin
    PC=
        icode==4'h8 ? valC:
        icode==4'h7 ? (Cnd ? valC : valP):
        icode==4'h9 ? valM : valP;
   end


endmodule