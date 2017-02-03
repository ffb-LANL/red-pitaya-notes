`timescale 1ns/1ps

module testbench_iv;
   reg clk;
   reg reset;
   reg [159:0]cfg; 
   wire [15:0]m_axis_tdata;
   reg  [15:0]s_axis_tdata,data;
   reg  [31:0] counter;
   wire m_axis_tvalid;
   reg s_axis_tvalid;
   //wire [31:0]M_AXIS_PHASE_tdata;
  // reg M_AXIS_PHASE_tready;
   //wire     M_AXIS_PHASE_tvalid;
   reg m_axis_tready;
      // Clock gen

   // reset logic
   initial begin
      counter=0;
      cfg = {32'd1024,32'd7186,32'd300000,16'd0,16'd480,16'd32,16'd255};
      reset = 1'b0;
      
      m_axis_tready = 1'b1;
      s_axis_tvalid = 1'b1;
      data = 50;
         //   M_AXIS_PHASE_tready =  1'b0;

      #50 reset = 1'b1;
      #10 s_axis_tvalid = 1'b1;
      #5000 data = 100;

    //  #300 m_axis_tready = 1'b0;

 //     #250 m_axis_tready = 1'b1;
 //     #50 m_axis_tready = 1'b0;
 //     #500 reset = 1'b0;
      #10000 data = 600;
 //     #10 reset = 1'b1;
 //     #50 m_axis_tready = 1'b1;
  //    #1000 s_axis_tvalid = 1'b0;
   end 
   
   always 
         begin 
          clk = 1'b1; 
          #(2) clk = 1'b0; 
          #(2); counter = counter+1;
         end
    always 
               begin 
                s_axis_tdata = 16'b0; 
                #(2048) s_axis_tdata =  data; 
                #(2048); 
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
       .M_AXIS_tready(m_axis_tready),
       .S_AXIS_tdata(s_axis_tdata),
       .S_AXIS_tvalid(s_axis_tvalid),
       .cfg_data(cfg)
   );
  endmodule // testbench