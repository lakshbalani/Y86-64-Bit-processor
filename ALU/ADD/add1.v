module add1(a,b,cin,sum,carry);
  input a,b,cin;
  output sum,carry;

  xor G1 (p,a,b);
  xor G2 (sum,cin,p);
  and G3 (q,p,cin);
  and G4 (r,a,b);
  or G5 (carry,q,r);

endmodule