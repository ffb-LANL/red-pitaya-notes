
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

  input  wire                        run_flag,
  input  wire                        trg_flag,

  // Master side
  output wire [AXIS_TDATA_WIDTH-1:0] m_axis_tdata,
  output wire                        m_axis_tvalid,
  input  wire                        m_axis_tready
);

  reg [CNTR_WIDTH-1:0] int_cntr_reg, int_cntr_next;
  reg int_run_reg, int_run_next;
  reg int_trg_reg, int_trg_next;

  always @(posedge aclk)
  begin
    if(~aresetn)
    begin
      int_cntr_reg <= {(CNTR_WIDTH){1'b0}};
      int_run_reg <= 1'b0;
      int_trg_reg <= 1'b0;
    end
    else
    begin
      int_cntr_reg <= int_cntr_next;
      int_run_reg <= int_run_next;
      int_trg_reg <= int_trg_next;
    end
  end

  begin 
     always @*
     begin
       int_cntr_next = int_cntr_reg;
       int_run_next = int_run_reg;
       int_trg_next = int_trg_reg;

       if(~int_run_reg & run_flag)
       begin
          int_run_next = 1'b1;
          int_trg_next = 1'b0;
       end

       if(int_run_reg & trg_flag)
       begin
          int_trg_next = 1'b1;
       end

       if( int_run_reg )
       begin
          int_cntr_next = int_cntr_reg + 1'b1;
       end

       if(int_trg_reg)
       begin       
          int_trg_next = 1'b0;
       end

     end
  end

  assign m_axis_tdata = int_trg_reg?{(CNTR_WIDTH){1'b0}}:int_cntr_reg;
  assign m_axis_tvalid = 1'b1;

endmodule
