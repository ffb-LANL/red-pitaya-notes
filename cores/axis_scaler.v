
`timescale 1 ns / 1 ps

module axis_scaler #
(
  parameter integer AXIS_TDATA_WIDTH = 14,
  parameter integer DSP_LATENCY = 2
)
(
  // System signals
  input  wire                        aclk,
  input  wire                        aresetn,

  input  wire               [31:0]   cfg_data,

    // Slave side
  input wire signed [AXIS_TDATA_WIDTH-1:0] s_axis_tdata,
  input wire                        s_axis_tvalid,
  output wire                       s_axis_tready,

    // Master side
  input  wire                        m_axis_tready,
  output wire signed [AXIS_TDATA_WIDTH-1:0] m_axis_tdata,
  output wire                        m_axis_tvalid

);
 
wire signed [15:0] scale;
wire signed [AXIS_TDATA_WIDTH+15:0] offset;
reg signed  [47:0] result;
// reg signed [47:0] dsp_result_pipeline [0:DSP_LATENCY-1];
reg dsp_valid_pipeline [0:DSP_LATENCY-1];
assign m_axis_tvalid = s_axis_tvalid; // dsp_valid_pipeline[0];

// Handshake logic
assign s_axis_tready = m_axis_tready; // || !m_axis_tvalid);
                   


assign scale = $signed(cfg_data[15:0]);
assign offset = $signed({cfg_data[AXIS_TDATA_WIDTH+15:AXIS_TDATA_WIDTH+15],cfg_data[AXIS_TDATA_WIDTH+15:16],15'b0});

integer i;

always @(posedge aclk)
    begin
	if(~aresetn)
      	  begin
            result <= 48'b0;
           // for (i = 0; i < DSP_LATENCY; i = i + 1) begin
            //    dsp_result_pipeline[i] <= 48'b0;
             //   dsp_valid_pipeline[i] <= 1'b0;
           // end
      	  end
    	else
    	  begin
            if (s_axis_tvalid && s_axis_tready) begin
                // Start new DSP operation
                (* use_dsp = "yes" *)
                result <= $signed(s_axis_tdata) * scale + offset;
              //  dsp_valid_pipeline[0] <= 1'b1;
            end

            // Pipeline the DSP results and valid signals
           // for (i = 1; i < DSP_LATENCY; i = i + 1) begin
                // dsp_result_pipeline[i] <= dsp_result_pipeline[i-1];
               // dsp_valid_pipeline[i] <= dsp_valid_pipeline[i-1];
            // end
          end
     end

assign m_axis_tdata = $signed(result[AXIS_TDATA_WIDTH+14:15]); 

endmodule
