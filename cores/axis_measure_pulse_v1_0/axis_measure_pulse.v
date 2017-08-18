
`timescale 1 ns / 1 ps

module axis_measure_pulse #
(
  parameter integer AXIS_TDATA_WIDTH = 16,
  parameter integer CNTR_WIDTH = 16,
  parameter integer PULSE_WIDTH = 16,
  parameter integer BRAM_DATA_WIDTH = 16,
  parameter integer BRAM_ADDR_WIDTH = 10
)
(
  // System signals
  input  wire                        aclk,
  input  wire                        aresetn,
 
  input  wire [PULSE_WIDTH*4+95:0]   cfg_data,
  output wire                        overload,
  output wire [2:0]                  case_id,
  output wire [31:0]                 sts_data,

  // Slave side
  output wire                        s_axis_tready,
  input wire  [AXIS_TDATA_WIDTH-1:0] s_axis_tdata,
  input  wire                        s_axis_tvalid,
  
    // Master side
  input  wire                        m_axis_tready,
  output wire [AXIS_TDATA_WIDTH-1:0] m_axis_tdata,
  output wire                        m_axis_tvalid,
  output wire                        m_axis_tlast,
  
    // BRAM port
  output wire                        bram_porta_clk,
  output wire                        bram_porta_rst,
  output wire [BRAM_ADDR_WIDTH-1:0]  bram_porta_addr,
  input  wire [BRAM_DATA_WIDTH-1:0]  bram_porta_rddata

);

  wire [PULSE_WIDTH-1:0] offset_start,ramp,width,offset_width;
  wire [BRAM_ADDR_WIDTH-1:0] waveform_length, pulse_length;
  wire signed [31:0] threshold;
  reg [CNTR_WIDTH-1:0] int_cntr_reg, int_cntr_next;
  reg [2:0] int_case_reg, int_case_next;
  reg signed [31:0] pulse,pulse_next,offset,offset_next,result,result_next;
  reg [BRAM_ADDR_WIDTH-1:0] wfrm_start,wfrm_start_next,wfrm_point,wfrm_point_next;

  reg [BRAM_ADDR_WIDTH-1:0] int_addr, int_addr_next;
  reg int_enbl_reg, int_enbl_next;
  reg int_conf_reg, int_conf_next;

  wire int_comp_wire, int_tlast_wire, wfrm_point_comp;
  
  assign offset_start = cfg_data[PULSE_WIDTH-1:0];
  assign ramp = cfg_data[PULSE_WIDTH*2-1:PULSE_WIDTH];
  assign width = cfg_data[PULSE_WIDTH*3-1:PULSE_WIDTH*2];
  assign offset_width = width[PULSE_WIDTH-2:1];


  assign threshold = $signed(cfg_data[PULSE_WIDTH*4+31:PULSE_WIDTH*4]);
  assign waveform_length = cfg_data[PULSE_WIDTH*4+BRAM_ADDR_WIDTH+31:PULSE_WIDTH*4+32];
  assign pulse_length = cfg_data[PULSE_WIDTH*4+BRAM_ADDR_WIDTH+63:PULSE_WIDTH*4+64];
  
  always @(posedge aclk)
  begin
    if(~aresetn)
    begin
      int_cntr_reg <= {(CNTR_WIDTH){1'b0}};
      int_case_reg <= 3'd0;
      pulse <= 32'd0; 
      offset <= 32'd0;              
      result <= 32'd0;
      wfrm_start <= {(BRAM_ADDR_WIDTH){1'b0}};
      wfrm_point <= {(BRAM_ADDR_WIDTH){1'b0}};
      int_addr <= {(BRAM_ADDR_WIDTH){1'b0}};
      int_enbl_reg <= 1'b0;
      int_conf_reg <= 1'b0;                           
    end
    else
    begin
      int_cntr_reg <= int_cntr_next;
      int_case_reg <= int_case_next;
      pulse <= pulse_next;
      offset <= offset_next;
      result <= result_next;
      wfrm_start <= wfrm_start_next;
      wfrm_point <= wfrm_point_next;
      int_addr <= int_addr_next;
      int_enbl_reg <= int_enbl_next;
      int_conf_reg <= int_conf_next;
    end
  end
  
  assign int_comp_wire = wfrm_start < waveform_length;
  assign int_tlast_wire = ~int_comp_wire;
  assign wfrm_point_comp = wfrm_point < pulse_length;
          
  always @*
     begin
      int_cntr_next = int_cntr_reg;
      int_case_next = int_case_reg;
      offset_next=offset;
      result_next=result;
      int_addr_next = int_addr;
      pulse_next = pulse;
      wfrm_start_next = wfrm_start;
      wfrm_point_next = wfrm_point;

      int_enbl_next = int_enbl_reg;

       if(~int_enbl_reg & int_comp_wire)
        begin
         int_enbl_next = 1'b1;
        end

       if(m_axis_tready & int_enbl_reg & wfrm_point_comp)
        begin
          wfrm_point_next = wfrm_point + 1'b1;
          int_addr_next = wfrm_start + wfrm_point;
       end

       if(m_axis_tready & int_enbl_reg & ~wfrm_point_comp)
       begin
         wfrm_point_next = 32'b0;
         int_addr_next = wfrm_start + wfrm_point;
       end

      case(int_case_reg)
    
       // measure signal offset
        0:
         begin
          if(s_axis_tvalid)
            begin
             if(int_cntr_reg < offset_width )
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

       // skip ramp up
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

       // measure pulse
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

       // skip ramp down
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
             if(int_cntr_reg < offset_width )
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
                wfrm_point_next = {(BRAM_ADDR_WIDTH){1'b0}};
                int_addr_next = wfrm_start + wfrm_point;

               if(($signed(result_next) < threshold) & int_comp_wire )
                  begin
                     wfrm_start_next = wfrm_start + pulse_length + 1;
                  end
                else 
                  begin
                     wfrm_start_next = {(BRAM_ADDR_WIDTH){1'b0}};;
                  end 
               end
            end
         end
       endcase
     end

  assign overload = result < threshold;
  assign s_axis_tready = 1'b1;
  
  assign m_axis_tdata = bram_porta_rddata;
  assign m_axis_tvalid = int_enbl_reg;
  assign m_axis_tlast = int_enbl_reg & int_tlast_wire;
  assign sts_data = result ;
  assign bram_porta_clk = aclk;
  assign bram_porta_rst = ~aresetn;
  assign bram_porta_addr = m_axis_tready & int_enbl_reg ? int_addr_next : int_addr;
  assign case_id = int_case_reg;
 // assign bram_porta_addr = int_addr;

endmodule