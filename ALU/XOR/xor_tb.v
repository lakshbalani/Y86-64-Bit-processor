module xor_tb;
 reg signed [63:0]a;
 reg signed [63:0]b;

 wire signed [63:0]out;

xor64 and_module (.out(out),.a(a),.b(b));


initial begin
    $dumpfile("Xor_test.vcd");
    $dumpvars(0,xor_tb);
    $monitor("       a=%b\n       b=%b\n  output=%b\n",a,b,out);
    a=64'b10011;
    b=64'b1010;
    #50;
    a=64'b101010011110010101110;
    b=64'b101010111110101;
    #50;
    a=64'b111100001000001;
    b=64'b1110001010111;
    #50;
    a=64'b1111000000000111110000111;
    b=64'b100000001000111;
    #50;
    a=64'b1111010101110001111100011111111110000001111000000111000011010001;
    b=64'b1111111111111111111110111100000000000000001110100010110111111000;
    #50;
end
endmodule