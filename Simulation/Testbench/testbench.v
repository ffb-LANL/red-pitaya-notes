`timescale 1ns/1ps

module testbench;
   reg clk;
   reg reset, trig;
   wire [15:0]m_axis_tdata;
   wire m_axis_tvalid, trig_out,clk_out;
   //wire [31:0]M_AXIS_PHASE_tdata;
  // reg M_AXIS_PHASE_tready;
   //wire     M_AXIS_PHASE_tvalid;
   reg m_axis_tready;
      // Clock gen
   initial begin
      clk = 1'b0;
      forever clk = #4 ~clk;
   end
 
   // reset logic
   initial begin
      m_axis_tready = 1'b0;
   //   M_AXIS_PHASE_tready =  1'b0;
      reset = 1'b0;
      trig=1'b0;
      #50 reset = 1'b0;

   //         M_AXIS_PHASE_tready =  1'b1;
      #500       trig=1'b1;
      #32 m_axis_tready = 1'b1;
      #50       trig=1'b0;
      #100      trig=1'b1;
      #300 m_axis_tready = 1'b0;
      #50       trig=1'b0;
      #100      trig=1'b1;
      #250 m_axis_tready = 1'b1;
      #50       trig=1'b0;
      #100      trig=1'b1;
   end
   
  //DUT test
   initial begin
       repeat(1000) @(negedge clk);
       $finish;
   end     
   
   //DUT
   DUT DUT_1 (
       .aclk(clk),
       .aresetn(rst),
       .trig(trig),
       .clk_out1(clk_out),
       .trig_out(trig_out),
       .M_AXIS_tdata(m_axis_tdata),
       .M_AXIS_tready(m_axis_tready),
       .M_AXIS_tvalid(m_axis_tvalid)
   );
  endmodule // testbench