`timescale 1ns/1ps

module testbench_4;
   reg clk;
   reg reset, trig,enable,enable_wr;
   wire [15:0]m_axis_tdata;
   reg  [15:0]s_axis_tdata;
   reg [15:0] cfg_data;
   wire m_axis_tvalid, m_axis_y_tvalid, trig_out,clk_out;
   reg s_axis_tvalid;
   wire s_axis_tready;
   reg m_axis_tready;
      // Clock gen

   // reset logic
   initial begin
      reset = 1'b0;
      m_axis_tready = 1'b0;
      s_axis_tvalid = 1'b1;
       s_axis_tdata = 50;
       cfg_data = 0;
         //   M_AXIS_PHASE_tready =  1'b0;

      #50 reset = 1'b1;
      m_axis_tready = 1'b1;
      #10 s_axis_tvalid = 1'b1;
      #50 s_axis_tdata = 100;
      cfg_data = 100;
    //  #300 m_axis_tready = 1'b0;

      #250 m_axis_tready = 1'b1;
      #50 m_axis_tready = 1'b0;
    //  #50 reset = 1'b0;
      #50 s_axis_tdata = 150;
      #50 reset = 1'b1;
      #50 m_axis_tready = 1'b1;
      #50 s_axis_tvalid = 1'b0;
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
   dut_4 dut_4 (
       .aclk(clk),
       .aresetn(reset),
       .M_AXIS_tdata(m_axis_tdata),
       .M_AXIS_tvalid(m_axis_tvalid),
       .M_AXIS_tready(m_axis_tready),
       .cfg_data(cfg_data)
   );
  endmodule // testbench