module xor64( output signed [63:0]out,input signed [63:0]a,input signed [63:0]b
);
 

 genvar i;

 generate
      for(i=0;i<64;i=i+1)
      begin
          xor G1 (out[i],a[i],b[i]);
      end
 endgenerate
 
endmodule