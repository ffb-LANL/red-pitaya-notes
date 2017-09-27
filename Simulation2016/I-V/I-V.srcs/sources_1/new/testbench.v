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
   //CIC connections
   wire [15:0]m_axis_CIC_tdata;
   reg [15:0]CIC_cfg; 
   reg  [15:0]s_axis_CIC_tdata;
   reg s_axis_CIC_tvalid;
   // reset logic
   initial begin
      counter=0;
      //  assign offset_start = cfg_data[PULSE_WIDTH-1:0]; [15:0]
     // assign ramp = cfg_data[PULSE_WIDTH*2-1:PULSE_WIDTH]; 31:16
      // assign width = cfg_data[PULSE_WIDTH*3-1:PULSE_WIDTH*2]; 47:32
      // assign offset_width = width[PULSE_WIDTH-2:1]; 46:33?
    // assign  threshold = $signed(cfg_data[PULSE_WIDTH*4+31:PULSE_WIDTH*4]); 95:64
      // assign waveform_length = cfg_data[PULSE_WIDTH*4+BRAM_ADDR_WIDTH+31:PULSE_WIDTH*4+32]; 111:96
      // pulse_length = cfg_data[PULSE_WIDTH*4+BRAM_ADDR_WIDTH+63:PULSE_WIDTH*4+64];  143:128
      //pulse_length=1024, waveform_length=7186;threshold=300000,width=480,ramp=16,offset_start=255;
      cfg = {32'd1023,32'd7185,32'd300000,16'd0,16'd479,16'd31,16'd255};
      reset = 1'b0;
      CIC_cfg = 64;
      m_axis_tready = 1'b1;
      s_axis_tvalid = 1'b1;
      data = 50;
      s_axis_CIC_tdata = 1000;
         //   M_AXIS_PHASE_tready =  1'b0;

      #50 reset = 1'b1;
      #10 s_axis_tvalid = 1'b1;
      #5000 data = 100;
      s_axis_CIC_tdata = 2000;
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
          #(2) counter = counter+1;

          
         end
         
            always 
               begin
                s_axis_CIC_tvalid =  1'b0;       
                #(60) s_axis_CIC_tvalid =  1'b1; 
                #(4);
              end
    always 
               begin 
                s_axis_tdata = 16'b0; 
                #(2048) s_axis_tdata =  data; 
                #(2048); 
    end
  //DUT test
   initial begin
       repeat(100000) @(negedge clk);
       $finish;
   end     
   
   //DUT
   DUT_IV_wrapper DUT_IV_wrapper (
       .aclk(clk),
       .aresetn(reset),
       .M_AXIS_tdata(m_axis_tdata),
       .M_AXIS_tvalid(m_axis_tvalid),
       .M_AXIS_tready(m_axis_tready),
       .S_AXIS_tdata(s_axis_tdata),
       .S_AXIS_tvalid(s_axis_tvalid),
       .cfg_data(cfg),
       .S_AXIS_DATA_tvalid(s_axis_CIC_tvalid),
       .S_AXIS_DATA_tdata(s_axis_CIC_tdata),
        .cfg_data_1(CIC_cfg),
       .M_AXIS_DATA_tready(1'b1),
       .M_AXIS_DATA_tdata(m_axis_CIC_tdata)
   );
  endmodule // testbench