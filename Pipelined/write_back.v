module write_back (valA,valB,valM,valE,dstE,dstM,srcA,srcB);
 output signed [63:0] valA,valB;
 input signed [63:0] valM,valE;
 input [3:0] dstE,dstM,srcA,srcB;

 reg [63:0] file [14:0];
 wire [63:0] nonreg;

 reg [63:0] __valA,__valB;
always@* begin
 if(srcA==4'hf) begin
  __valA=64'h0;
 end
end

always@* begin
 if(srcA!=4'hf) begin
  __valA=file[srcA];
 end
end

always@* begin
 if(srcB==4'hf) begin
  __valB=64'h0;
 end
end

always@* begin
 if(srcB!=4'hf) begin
  __valB=file[srcB];
 end
end

assign valA=__valA;
assign valB=__valB;


//write-back
always @* begin

    if(dstE<4'hf) begin
        file[dstE]=valE;
    end
end

always @* begin

    if(dstM<4'hf) begin
        file[dstM]=valM;
    end
end

endmodule