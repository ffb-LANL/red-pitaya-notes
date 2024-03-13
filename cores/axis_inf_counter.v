
`timescale 1 ns / 1 ps

module axis_inf_counter #
(
  parameter integer AXIS_TDATA_WIDTH = 32,
  parameter integer CNTR_WIDTH = 32
)
(
  // System signals
  input  wire                        aclk,
  input  wire                        aresetn,


  // Master side
  output wire [AXIS_TDATA_WIDTH-1:0] m_axis_tdata,
  output wire                        m_axis_tvalid,
  input  wire                        m_axis_tready
);

  reg [CNTR_WIDTH-1:0] int_cntr_reg, int_cntr_next;
  reg int_enbl_reg, int_enbl_next;


  always @(posedge aclk)
  begin
    if(~aresetn)
    begin
      int_cntr_reg <= {(CNTR_WIDTH){1'b0}};
      int_enbl_reg <= 1'b0;
    end
    else
    begin
      int_cntr_reg <= int_cntr_next;
      int_enbl_reg <= int_enbl_next;
    end
  end

    begin 
      always @*
      begin
        int_cntr_next = int_cntr_reg;
        int_enbl_next = int_enbl_reg;

        if(~int_enbl_reg )
        begin
          int_enbl_next = 1'b1;
        end

        if( int_enbl_reg )
        begin
          int_cntr_next = int_cntr_reg + 1'b1;
        end
      end
    end

  assign m_axis_tdata = int_cntr_reg;
  assign m_axis_tvalid = int_enbl_reg;

endmodule
