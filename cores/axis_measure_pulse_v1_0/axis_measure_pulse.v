
`timescale 1 ns / 1 ps

module axis_measure_pulse #
(
  parameter integer CNTR_WIDTH = 32,
  parameter integer PULSE_WIDTH = 16
)
(
  // System signals
  input  wire                        aclk,
  input  wire                        aresetn,
 
  input  wire [PULSE_WIDTH*4+31:0]   cfg_data,

  output wire                        overload,
  output wire [31:0]                 sts_data,

  // Slave side
  output wire                        s_axis_tready,
  input wire                         s_axis_tdata,
  input  wire                        s_axis_tvalid
);

wire [PULSE_WIDTH-1:0] pre_offset,ramp,width,post_offset;
wire [31:0] threshold;
reg [CNTR_WIDTH-1:0] int_cntr_reg, int_cntr_next, int_trigger_pos, int_trigger_pos_next;
reg [2:0] int_case_reg, int_case_next;
reg [31:0] pulse,pulse_next,offset,offset_next,result,result_next;
  
  assign pre_offset = cfg_data[PULSE_WIDTH-1:0];
  assign ramp = cfg_data[PULSE_WIDTH*2-1:PULSE_WIDTH];
  assign width = cfg_data[PULSE_WIDTH*3-1:PULSE_WIDTH*2];
  assign post_offset = cfg_data[PULSE_WIDTH*4-1:PULSE_WIDTH*3];
  assign threshold = cfg_data[PULSE_WIDTH*4+31:PULSE_WIDTH*4];

  always @(posedge aclk)
  begin
    if(~aresetn)
    begin
      int_cntr_reg <= {(CNTR_WIDTH){1'b0}};
      int_case_reg <= 3'd0;
      pulse <= 32'd0; 
      offset <= 32'd0;              
      result <= 32'd0;                           
    end
    else
    begin
      int_cntr_reg <= int_cntr_next;
      int_case_reg <= int_case_next;
      pulse <= pulse_next;
      offset <= offset_next;
      result <= result_next;
    end
  end
        
  always @*
     begin
      int_cntr_next = int_cntr_reg;
      int_case_next = int_case_reg;
      offset_next=offset;
      result_next=result;

      case(int_case_reg)
       // pre offset
        0:
         begin
          if(s_axis_tvalid)
            begin
             if(int_cntr_reg < pre_offset )
               begin
                offset_next = $signed(offset) + $signed(s_axis_tdata);
                int_cntr_next = int_cntr_reg + 1'b1;
               end
             else
               begin
                int_cntr_next = {(CNTR_WIDTH){1'b0}};
                int_case_next = int_case_reg + 3'd1;
               end
            end
         end

       // ramp up
        1:
         begin
          if(s_axis_tvalid)
            begin
             if(int_cntr_reg < ramp )
               begin
                int_cntr_next = int_cntr_reg + 1'b1;
               end
             else
               begin
                int_cntr_next = {(CNTR_WIDTH){1'b0}};  
                int_case_next = int_case_reg + 3'd1;
               end
            end
         end

       // pulse
        2:
         begin
          if(s_axis_tvalid)
            begin
             if(int_cntr_reg < width )
               begin
                pulse_next = $signed(pulse) + $signed(s_axis_tdata);
                int_cntr_next = int_cntr_reg + 1'b1;
               end
             else
               begin
                int_cntr_next = {(CNTR_WIDTH){1'b0}};
                int_case_next = int_case_reg + 3'd1;
               end
            end
         end

       // ramp down
        3:
         begin
          if(s_axis_tvalid)
            begin
             if(int_cntr_reg < ramp )
               begin
                int_cntr_next = int_cntr_reg + 1'b1;
               end
             else
               begin
                int_cntr_next = {(CNTR_WIDTH){1'b0}};  
                int_case_next = int_case_reg + 3'd1;
               end
            end
         end

       // post offset
        4:
         begin
          if(s_axis_tvalid)
            begin
             if(int_cntr_reg < pre_offset )
               begin
                offset_next = $signed(offset) + $signed(s_axis_tdata);
                int_cntr_next = int_cntr_reg + 1'b1;
               end
             else
               begin
                int_cntr_next = {(CNTR_WIDTH){1'b0}};
                int_case_next = 3'd0;
                result_next = $signed(pulse) - $signed(offset); // assume 50% duty cycle
                offset_next = 32'd0;
                pulse_next = 32'd0;
               end
            end
         end
       endcase
      end

  assign overload = result < threshold;
  assign s_axis_tready = 1'b1;

endmodule