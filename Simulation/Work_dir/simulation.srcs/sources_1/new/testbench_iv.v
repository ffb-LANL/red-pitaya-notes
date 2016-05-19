`timescale 1ns/1ps

module testbench_iv;
   reg clk;
   reg reset, trig,enable,enable_wr;
   reg [159:0]cfg; 
   wire [15:0]m_axis_tdata;
   reg  [15:0]s_axis_tdata;
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
      cfg = {32'd2048,32'd6144,32'd94372,16'd0,16'd240,16'd16,16'd120};
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

 //     #250 m_axis_tready = 1'b1;
 //     #50 m_axis_tready = 1'b0;
 //     #500 reset = 1'b0;
      #1000 s_axis_tdata = 300;
 //     #10 reset = 1'b1;
 //     #50 m_axis_tready = 1'b1;
  //    #1000 s_axis_tvalid = 1'b0;
   end 
   
   always 
         begin 
          clk = 1'b1; 
          #(2) clk = 1'b0; 
          #(2); 
         end
   
  //DUT test
   initial begin
       repeat(20000) @(negedge clk);
       $finish;
   end     
   
   //DUT
   DUT_IV DUT_IV (
       .aclk(clk),
       .aresetn(reset),
       .M_AXIS_tdata(m_axis_tdata),
       .M_AXIS_tvalid(m_axis_tvalid),
       .M_AXIS_tready(1'b1),
       .S_AXIS_tdata(s_axis_tdata),
       .S_AXIS_tvalid(s_axis_tvalid),
       .cfg_data(cfg)
   );
  endmodule // testbench