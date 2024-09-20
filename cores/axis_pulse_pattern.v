
`timescale 1 ns / 1 ps

module axis_pulse_pattern #
(
  parameter integer AXIS_TDATA_WIDTH = 16,
  parameter integer CNTR_WIDTH = 16,
  parameter integer PULSE_WIDTH = 16,
  parameter integer BRAM_DATA_WIDTH = 16,
  parameter integer BRAM_ADDR_WIDTH = 16
)
(
  // System signals
  input  wire                        aclk,
  input  wire                        aresetn,
 
  input  wire [PULSE_WIDTH*4+95:0]   cfg_data,
  input  wire                        trg_flag,
  output wire                        overload,
  output wire [2:0]                  case_id,
  output wire [31:0]                 sts_data,
  output wire [31:0]                 pulse_count,

  // Slave side
  output wire                        s_axis_tready,
  input wire  [AXIS_TDATA_WIDTH-1:0] s_axis_tdata,
  input  wire                        s_axis_tvalid,
  
    // Master side
  input  wire                        m_axis_tready,
  output wire [AXIS_TDATA_WIDTH-1:0] m_axis_tdata,
  output wire                        m_axis_tvalid,
  output wire                        m_axis_tlast,
  
    // Master side
  input  wire                        m01_axis_tready,
  output wire [32-1:0] 		     m01_axis_tdata,
  output wire                        m01_axis_tvalid,

    // BRAM port
  (* X_INTERFACE_INFO = "xilinx.com:interface:bram:1.0 bram CLK" *)
  output wire                        bram_clk,
  (* X_INTERFACE_INFO = "xilinx.com:interface:bram:1.0 bram RST" *)
  output wire                        bram_rst,
  (* X_INTERFACE_INFO = "xilinx.com:interface:bram:1.0 bram ADDR" *)
  output wire [BRAM_ADDR_WIDTH-1:0]  bram_addr,
  (* X_INTERFACE_INFO = "xilinx.com:interface:bram:1.0 bram DOUT" *)
  input  wire [BRAM_DATA_WIDTH-1:0]  bram_rddata

);

  reg int_trg_reg,int_sts_tvalid_reg,int_sts_tvalid_next;

  wire [PULSE_WIDTH-1:0] total_sweeps,ramp,width,offset_width;
  wire [BRAM_ADDR_WIDTH-1:0] waveform_length, pulse_length;
  wire signed [31:0] threshold, magnitude;
  reg [CNTR_WIDTH-1:0] int_cntr_reg, int_cntr_next, int_cntr_sweeps_reg, int_cntr_sweeps_next,int_pulse_count_reg,int_pulse_count_next,int_pulse_step_reg,int_pulse_step_next,pulse_step_reg,pulse_step_next;
  reg [2:0] int_case_reg, int_case_next;
  reg signed [31:0] pulse,pulse_next,offset,offset_next,result,result_next;
  reg [BRAM_ADDR_WIDTH-1:0] wfrm_start,wfrm_start_next,wfrm_point,wfrm_point_next;
 
  reg [BRAM_ADDR_WIDTH-1:0] int_addr, int_addr_next;
  reg int_enbl_reg, int_enbl_next;
  reg int_last_pulse_reg, int_last_pulse_next;

  wire int_comp_wire, int_tlast_wire, wfrm_point_comp;
  // default cfg_data: total_sweeps[16]:ramp[16]:width[16]:unused[16]:threshold[32]:waveform_length[32]:pulse_length[32]
  assign total_sweeps = cfg_data[PULSE_WIDTH-1:0];
  assign ramp = cfg_data[PULSE_WIDTH*2-1:PULSE_WIDTH];
  assign width = cfg_data[PULSE_WIDTH*3-1:PULSE_WIDTH*2];
  assign offset_width = width[PULSE_WIDTH-2:1];


  assign threshold = $signed(cfg_data[PULSE_WIDTH*4+31:PULSE_WIDTH*4]);
  assign waveform_length = cfg_data[PULSE_WIDTH*4+BRAM_ADDR_WIDTH+31:PULSE_WIDTH*4+32];
  assign pulse_length = cfg_data[PULSE_WIDTH*4+BRAM_ADDR_WIDTH+63:PULSE_WIDTH*4+64];
  assign magnitude = $signed(pulse) - $signed(offset);
  
  always @(posedge aclk)
  begin
    if(~aresetn)
    begin
      int_cntr_reg <= {(CNTR_WIDTH){1'b0}};
      int_cntr_sweeps_reg <= {(CNTR_WIDTH){1'b0}};
      int_pulse_count_reg <= {(CNTR_WIDTH){1'b0}};
      int_pulse_step_reg <= {(CNTR_WIDTH){1'b0}};
      pulse_step_reg <= {(CNTR_WIDTH){1'b0}};
      int_case_reg <= 3'd0;
      pulse <= 32'd0; 
      offset <= 32'd0;              
      result <= 32'd0;
      wfrm_start <= {(BRAM_ADDR_WIDTH){1'b0}};
      wfrm_point <= {(BRAM_ADDR_WIDTH){1'b0}};
      int_addr <= {(BRAM_ADDR_WIDTH){1'b0}};
      int_enbl_reg <= 1'b0;
      int_last_pulse_reg <= 1'b0;    
      int_trg_reg <= 1'b0;   
      int_sts_tvalid_reg <= 1'b0;                   
    end
    else
    begin
      if(trg_flag)
      begin
        int_trg_reg <= 1'b1;
      end
      int_sts_tvalid_reg <= int_sts_tvalid_next; 
      int_cntr_reg <= int_cntr_next;
      int_pulse_count_reg <= int_pulse_count_next;
      int_pulse_step_reg <= int_pulse_step_next;
      pulse_step_reg <= pulse_step_next;
      int_cntr_sweeps_reg <= int_cntr_sweeps_next;
      int_case_reg <= int_case_next;
      pulse <= pulse_next;
      offset <= offset_next;
      result <= result_next;
      wfrm_start <= wfrm_start_next;
      wfrm_point <= wfrm_point_next;
      int_addr <= int_addr_next;
      int_enbl_reg <= int_enbl_next;
      int_last_pulse_reg <= int_last_pulse_next;
    end
  end
  
  assign int_comp_wire = wfrm_start < waveform_length;
  assign int_tlast_wire = ~int_comp_wire;
  assign wfrm_point_comp = wfrm_point < pulse_length;
          
  always @*
    begin
        int_cntr_next = int_cntr_reg;
        int_pulse_count_next = int_pulse_count_reg;
        int_pulse_step_next = int_pulse_step_reg;
        pulse_step_next = pulse_step_reg;
        int_cntr_sweeps_next = int_cntr_sweeps_reg;
        int_case_next = int_case_reg;
        offset_next=offset;
        result_next=result;
        int_addr_next = int_addr;
        pulse_next = pulse;
        wfrm_start_next = wfrm_start;
        wfrm_point_next = wfrm_point;
        int_enbl_next = int_enbl_reg;
        int_last_pulse_next = int_last_pulse_reg;
	int_sts_tvalid_next = int_sts_tvalid_reg;
 	
	if(int_sts_tvalid_reg & m01_axis_tready)
            int_sts_tvalid_next = 1'b0;

        if(int_trg_reg & (int_case_reg < 3'd5))
            begin
		// check if it is the last pulse in the waveform stored in memory
                if(wfrm_start < ( waveform_length - pulse_length) )
                    int_last_pulse_next = 1'b0;
                else
                    int_last_pulse_next = 1'b1;

                if(~int_enbl_reg & int_comp_wire)
                    int_enbl_next = 1'b1;
                    
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
                if(s_axis_tvalid)
                    begin
                        case(int_case_reg)
    
                            // measure signal offset front
                            0:
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

                            // ramp up, do not measure
                            1:
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

                            // measure pulse
                            2:
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

                            // ramp down, do not measure
                            3:
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


                            4:
                                begin
                                    if(int_cntr_reg < offset_width )
                                        // measure the rest signal offset 
                                        begin
                                            offset_next = $signed(offset) + $signed(s_axis_tdata);
                                            int_cntr_next = int_cntr_reg + 1'b1;
                                        end
                                    else
                                        // deside on the next action
                                        begin
                                            int_cntr_next = {(CNTR_WIDTH){1'b0}};
				            int_pulse_count_next = int_pulse_count_reg+1;
                                            int_case_next = 3'd0;
	    				    // calculate pulse magnitude
                                            result_next = magnitude; // assume 50% duty cycle
					    pulse_step_next = int_pulse_step_reg+1;
    					    int_sts_tvalid_next = 1'b1;
                                            offset_next = 32'd0;
                                            pulse_next = 32'd0;
                                            wfrm_point_next = {(BRAM_ADDR_WIDTH){1'b0}};
                                            int_addr_next = wfrm_start + wfrm_point;
					   
                                            if((magnitude < threshold) & ~int_last_pulse_reg )
						// ouput next pulse in the pattern
                                                begin
                                                    wfrm_start_next = wfrm_start + pulse_length + 1;
				            	    int_pulse_step_next = int_pulse_step_reg+1;
                                                end    
                                            else
					        // go back to 1st pulse in the pattern
                                                begin 
                                                    wfrm_start_next = {(BRAM_ADDR_WIDTH){1'b0}};
				            	    int_pulse_step_next = {(CNTR_WIDTH){1'b0}};
                                                    if(int_cntr_sweeps_reg < total_sweeps )
                                                        begin
                                                            int_cntr_sweeps_next = int_cntr_sweeps_reg + 1'b1;
                                                        end   
                                                    else
                                                        begin
                                                            int_enbl_next = 1'b0;
                                                            wfrm_point_next = {(BRAM_ADDR_WIDTH){1'b0}};
                                                            int_case_next = 3'd5;
                                                        end
                                                end
                                        end 
                                end
                            5:
                                begin
                                    int_enbl_next = 1'b0;
                                    wfrm_start_next = {(BRAM_ADDR_WIDTH){1'b0}};
                                    wfrm_point_next = {(BRAM_ADDR_WIDTH){1'b0}};
                                end
                        endcase
                    end
            end
    end
  assign overload = result < threshold;
  assign s_axis_tready = 1'b1;
  
  assign m_axis_tdata = bram_rddata;
  assign m_axis_tvalid = int_enbl_reg;
  assign m_axis_tlast = int_enbl_reg & int_tlast_wire;
//  assign sts_data = result ;
  assign sts_data = {result[31:8],5'b0,int_case_reg};
  assign pulse_count = int_pulse_count_reg;
  assign bram_clk = aclk;
  assign bram_rst = ~aresetn;
  assign bram_addr = m_axis_tready & int_enbl_reg ? int_addr_next : int_addr;
  assign case_id = int_case_reg;
  assign m01_axis_tdata = {pulse_step_reg[6:0],result[24:0]};
  assign m01_axis_tvalid = int_sts_tvalid_reg;
 // assign bram_addr = int_addr;

endmodule