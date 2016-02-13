`timescale 1ns/1ps

module testbench;
   reg clk;
   reg reset;
   // Clock gen
   initial begin
      clk = 1'b0;
      forever clk = #2.5 ~clk;
   end
 
   // reset logic
   initial begin
      reset = 1'b1;
      #10 reset = 1'b0;
   end
   
  //DUT test
   initial begin
      repeat(100) @(negedge clk);
       $finish;
   end     
  endmodule // testbench