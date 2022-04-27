module mem_1 (mem_r,mem_w,mem_add,mem_data,icode,valE,valA,valP);
 
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


 input [3:0] icode;
 input [63:0] valA;
 input [63:0] valE;
 input [63:0] valP;

 output mem_r;
 output mem_w;
 output [63:0] mem_add;
 output [63:0] mem_data;

 wire mem_r,mem_w;
 assign mem_r =(icode == IMRMOVQ | icode == IPOPQ | icode == IRET);
 assign mem_w =(icode == IRMMOVQ | icode == IPUSHQ | icode == ICALL);
 
 assign mem_addr =
 icode == IRMMOVQ ? valE :
 icode == IPUSHQ ? valE :
 icode == ICALL ? valE :
 icode == IMRMOVQ ? valE : valA;
 assign mem_data=(icode==IRMMOVQ||icode==IPUSHQ) ? valA : valP;

endmodule

module mem_2 (valM,dmem_error,mem_r,mem_w,mem_add,mem_data);
 input mem_r,mem_w;
 input [63:0] mem_add;
 input [63:0] mem_data;
 output dmem_error;
 output [63:0] valM;

 reg [63:0] mem [4095:0];
 reg [63:0] __valM;

always @ (*) begin
     if(mem_add<=64'h0FFF&&mem_add>=64'h0) begin
        if(mem_r ^ mem_w) 
        begin
        
        if(mem_w == 1'b1) 
        begin
        mem[mem_add] = mem_data;
        end

        if ( mem_r == 1'b1 ) begin 
                 __valM [63:56] = mem[mem_add]  ;
                 __valM [55:48] = mem[mem_add+1]  ;
                 __valM [47:40] = mem[mem_add+2]  ;
                 __valM [39:32] = mem[mem_add+3]  ;
                 __valM [33:24] = mem[mem_add+4]  ;
                 __valM [23:16] = mem[mem_add+5]  ;
                 __valM [15:8 ] = mem[mem_add+6]  ;
                 __valM [ 7:0 ] = mem[mem_add+7]  ;
            end 

        end 
     end  
end
assign valM=__valM;

endmodule