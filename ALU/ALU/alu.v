`include "../ALU/ADD/add64.v"
`include "../ALU/AND/and64.v"
`include "../ALU/SUB/sub64.v"
`include "../ALU/XOR/xor64.v"

module ALU(
  output signed [63:0]ans,
  output overflow,
  input [1:0]sel,
  input signed[63:0]a,
  input signed[63:0]b
  );

  wire signed [63:0]out_add;
  wire signed [63:0]out_and;
  wire signed [63:0]out_sub;
  wire signed [63:0]out_xor;

  add64 g1(out_add,overflow1,a,b);
  and64 g2(out_and,a,b);
  assign overflow2=1'b0;
  sub64 g3(out_sub,overflow3,a,b);
  xor64 g4(out_xor,a,b);
  assign overflow4=1'b0;

  reg signed [63:0]__ans;
  reg __overflow;

  always@*
  begin
	if(sel==2'b00)
	begin
        __ans=out_add;
        __overflow=overflow1;
	end

        else if(sel==2'b01)
	begin
        __ans=out_sub;
        __overflow=overflow3;
	end
	
	else if(sel==2'b10)
	begin
        __ans=out_and;
        __overflow=overflow2;
	end

	else if(sel==2'b11)
	begin
        __ans=out_xor;
        __overflow=overflow4;
	end
	
	end	

    assign ans= __ans;
    assign overflow= __overflow;
	
endmodule