// `include "add1.v"

module add1(a,b,cin,sum,carry);
  input a,b,cin;
  output sum,carry;

  xor G1 (p,a,b);
  xor G2 (sum,cin,p);
  and G3 (q,p,cin);
  and G4 (r,a,b);
  or G5 (carry,q,r);

endmodule

module add64( output signed [63:0]out, output overflow, input signed [63:0]a, input signed [63:0]b);
 
 wire [64:0]c;
 assign c[0]=1'b0;
 genvar i;

 generate
      for(i=0;i<64;i=i+1)
      begin
          add1 G1 (a[i],b[i],c[i],out[i],c[i+1]);
      end
 endgenerate

xor g2(overflow,c[63],c[64]);
 
endmodule