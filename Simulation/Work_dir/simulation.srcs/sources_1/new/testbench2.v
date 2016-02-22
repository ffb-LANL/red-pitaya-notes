`timescale 1ns/1ps

module testbench_2;
   reg clk;
   reg reset, trig,enable,enable_wr;
   wire [15:0]m_axis_tdata;
   wire m_axis_tvalid, trig_out,clk_out;
   //wire [31:0]M_AXIS_PHASE_tdata;
  // reg M_AXIS_PHASE_tready;
   //wire     M_AXIS_PHASE_tvalid;
   reg m_axis_tready;
      // Clock gen

   // reset logic
   initial begin
      reset = 1'b0;
      trig=1'b0;
      enable=1'b0;
      enable_wr = 1'b0;
      m_axis_tready = 1'b0;
   //   M_AXIS_PHASE_tready =  1'b0;


      #50 reset = 1'b1;
      #100 enable = 1'b1;
      enable_wr = 1'b1;
      #32 m_axis_tready = 1'b1;
      #800       trig=1'b1;


      #300 m_axis_tready = 1'b0;
      #500 trig=1'b0;
      enable=1'b0;
      enable_wr = 1'b0;
      #50
      enable=1'b1;
      enable_wr = 1'b1;
      #100      trig=1'b1;
      #250 m_axis_tready = 1'b1;
      #100      trig=1'b1;
   end
   
   always 
         begin 
          clk = 1'b1; 
          #(2) clk = 1'b0; 
          #(2); 
         end
   
  //DUT test
   initial begin
       repeat(1000) @(negedge clk);
       $finish;
   end     
   
   //DUT
   DUT_2 DUT_2 (
       .aclk(clk),
       .aresetn(reset),
       .trig(trig),
       .cfg_data(32'b11010),
       .enable(enable),
       .enable_wr(enable_wr),
       .M_AXI_awready(1'b1),
       .M_AXI_wready(1'b1)
   );
  endmodule // testbench