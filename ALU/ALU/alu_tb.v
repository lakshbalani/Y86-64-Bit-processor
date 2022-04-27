module alu_tb;
 reg signed [63:0]a;
 reg signed [63:0]b;
 reg [1:0]sel;

 wire signed [63:0]ans;
 wire overflow;


ALU alu_module (.ans(ans),.overflow(overflow),.sel(sel),.a(a),.b(b));


initial begin
    $dumpfile("Alu_test.vcd");
    $dumpvars(0,alu_tb);
    $monitor("       a=%b\n       b=%b\n     sel=%b\n  output=%b\noverflow=%b\n",a,b,sel,ans,overflow);
    a=64'b10011;
    b=64'b1010;
    sel=2'b00;
    #50;
    a=64'b101010011110010101110;
    b=64'b101010111110101;
    sel=2'b01;
    #50;
    a=64'b111100001000001;
    b=64'b1110001010111;
    sel=2'b10;
    #50;
    a=64'b1111000000000111110000111;
    b=64'b100000001000111;
    sel=2'b00;
    #50;
    a=64'b1111010101110001111100011111111110000001111000000111000011010001;
    b=64'b1111111111111111111110111100000000000000001110100010110111111000;
    sel=2'b11;
    #50;
    a=64'b1111000000000111110000111;
    b=64'b100000001000111;
    sel=2'b10;
    #50;
    a=64'b111100001000001;
    b=64'b1110001010111;
    sel=2'b11;
    #50;
end
endmodule