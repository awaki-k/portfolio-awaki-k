set_units -time ns

# =====================================================
# Clock definition (133MHz)
# =====================================================
create_clock -name clk -period 7.5 -waveform {0 3.75} [get_ports clk]

# =====================================================
# Input delays (20% of clock = 1.5ns)
# =====================================================
set_input_delay -clock clk -max 1.5 [get_ports reset]
set_input_delay -clock clk -max 1.5 [get_ports exec]
set_input_delay -clock clk -max 1.5 [get_ports tready]
set_input_delay -clock clk -max 1.5 [get_ports x1_wr_en]
set_input_delay -clock clk -max 1.5 [get_ports x1_wr_data[*]]

# =====================================================
# Output delays (20% of clock = 1.5ns)
# =====================================================
set_output_delay -clock clk -max 1.5 [get_ports pred_out[*]]
set_output_delay -clock clk -max 1.5 [get_ports tvalid]
