`timescale 1ns/1ps

module testbench_3;
   reg clk;
   reg reset, trig,enable,enable_wr;
   wire [31:0]m_axis_tdata;
   wire [31:0]m_axis_y_tdata;
   wire m_axis_tvalid, m_axis_y_tvalid, trig_out,clk_out;
   //wire [31:0]M_AXIS_PHASE_tdata;
  // reg M_AXIS_PHASE_tready;
   //wire     M_AXIS_PHASE_tvalid;
   reg m_axis_tready;
   reg m_axis_y_tready;
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
      m_axis_y_tready = 1'b1;
      #800       trig=1'b1;


    //  #300 m_axis_tready = 1'b0;
      #500 trig=1'b0;
      enable=1'b0;
      enable_wr = 1'b0;
      #50
      enable=1'b1;
      enable_wr = 1'b1;
      #100      trig=1'b1;
  //    #250 m_axis_tready = 1'b1;
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
       repeat(5000000) @(negedge clk);
       $finish;
   end     
   
   //DUT
   dut_3 dut_3 (
       .aclk(clk),
       .aresetn(reset),
       .M_AXIS_tdata(m_axis_tdata),
       .M_AXIS_tvalid(m_axis_tvalid),
       .M_AXIS_Y_tdata(m_axis_y_tdata),
 
       .M_AXIS_Y_tvalid(m_axis_y_tvalid)
   );
  endmodule // testbench