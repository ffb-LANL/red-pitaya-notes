`timescale 1ns/1ps

module testbench_5;
   reg clk;
   reg reset, trig,enable,enable_wr;
   wire [31:0]m_axis_tdata;
   reg  [31:0]s_axis_tdata;
   wire [31:0]m_axis_y_tdata;
   wire m_axis_tvalid, m_axis_y_tvalid, trig_out,clk_out;
   reg s_axis_tvalid;
   wire s_axis_tready;
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
      s_axis_tvalid = 1'b1;
       s_axis_tdata = 50;
         //   M_AXIS_PHASE_tready =  1'b0;

      #50 reset = 1'b1;
      #10 s_axis_tvalid = 1'b1;
      #50 s_axis_tdata = 100;

    //  #300 m_axis_tready = 1'b0;

      #250 m_axis_tready = 1'b1;
      #50 m_axis_tready = 1'b0;
      #500 reset = 1'b0;
      #10 s_axis_tdata = 300;
      #10 reset = 1'b1;
      #50 m_axis_tready = 1'b1;
      #1000 s_axis_tvalid = 1'b0;
   end 
   
   always 
         begin 
          clk = 1'b1; 
          #(2) clk = 1'b0; 
          #(2); 
         end
   
  //DUT test
   initial begin
       repeat(10000) @(negedge clk);
       $finish;
   end     
   
   //DUT
   dut_5 dut_5 (
       .aclk(clk),
       .aresetn(reset),
       .M_AXIS_tdata(m_axis_tdata),
       .M_AXIS_tvalid(m_axis_tvalid),
       .S_AXIS_tdata(s_axis_tdata),
       .S_AXIS_tvalid(s_axis_tvalid)
   );
  endmodule // testbench