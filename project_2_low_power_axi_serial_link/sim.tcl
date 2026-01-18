# -----------------------------------------------------------------------
#              SERIAL LINK SIMULATION FILE
#
# Author: Filippo Christen
# Date: 15.07.2025
#
# -----------------------------------------------------------------------

quit -sim
vlog -refresh

# Simulation Run
puts "#------> Running Simulation ------"
vsim -t 1fs -voptargs=+acc work.tb_serial_link -v2k_int_delays -sv_seed random +no_glitch_msg +bus_conflict_off

# Load the wave window
view wave
view signals

add wave -divider "TB"
add wave -position insertpoint sim:/tb_serial_link/*

add wave -divider "PHY wrapper 1"
add wave -position insertpoint sim:/tb_serial_link/i_serial_link_1/i_phy_wrapper/*
add wave -position insertpoint sim:/tb_serial_link/i_serial_link_1/i_phy_wrapper/i_synchronizer/*
add wave -divider "PHY wrapper 2"
add wave -position insertpoint sim:/tb_serial_link/i_serial_link_2/i_phy_wrapper/*

add wave -divider "1 to 2 pipeline"
add wave -position insertpoint sim:/tb_serial_link/i_serial_link_1/a_n2d_data
add wave -position insertpoint sim:/tb_serial_link/i_serial_link_1/a_n2d_header
add wave -position insertpoint sim:/tb_serial_link/i_serial_link_1/a_n2d_valid
add wave -position insertpoint sim:/tb_serial_link/i_serial_link_1/a_n2d_ready
add wave -position insertpoint sim:/tb_serial_link/i_serial_link_1/i_data_link_layer/a_data_ser1a
add wave -position insertpoint sim:/tb_serial_link/i_serial_link_1/i_data_link_layer/a_valid_ser1a
add wave -position insertpoint sim:/tb_serial_link/i_serial_link_1/i_data_link_layer/a_ready_ser1a
add wave -position insertpoint sim:/tb_serial_link/i_serial_link_1/i_data_link_layer/a_data_ser1b
add wave -position insertpoint sim:/tb_serial_link/i_serial_link_1/i_data_link_layer/a_valid_ser1b
add wave -position insertpoint sim:/tb_serial_link/i_serial_link_1/i_data_link_layer/a_ready_ser1b
add wave -position insertpoint sim:/tb_serial_link/i_serial_link_1/i_data_link_layer/a_data_ser2
add wave -position insertpoint sim:/tb_serial_link/i_serial_link_1/i_data_link_layer/a_valid_ser2
add wave -position insertpoint sim:/tb_serial_link/i_serial_link_1/i_data_link_layer/a_ready_ser2
add wave -position insertpoint sim:/tb_serial_link/i_serial_link_1/i_data_link_layer/a_data_ser3
add wave -position insertpoint sim:/tb_serial_link/i_serial_link_1/i_data_link_layer/a_valid_ser3
add wave -position insertpoint sim:/tb_serial_link/i_serial_link_1/i_data_link_layer/a_ready_ser3
add wave -position insertpoint sim:/tb_serial_link/i_serial_link_1/a_d2p_data
add wave -position insertpoint sim:/tb_serial_link/i_serial_link_2/i_phy_wrapper/i_synchronizer/correction_shift_q
add wave -position insertpoint sim:/tb_serial_link/i_serial_link_2/s_p2d_data
add wave -position insertpoint sim:/tb_serial_link/i_serial_link_2/i_data_link_layer/s_data_ser3
add wave -position insertpoint sim:/tb_serial_link/i_serial_link_2/i_data_link_layer/s_valid_ser3
add wave -position insertpoint sim:/tb_serial_link/i_serial_link_2/i_data_link_layer/s_ready_ser3
add wave -position insertpoint sim:/tb_serial_link/i_serial_link_2/i_data_link_layer/s_data_ser2
add wave -position insertpoint sim:/tb_serial_link/i_serial_link_2/i_data_link_layer/s_valid_ser2
add wave -position insertpoint sim:/tb_serial_link/i_serial_link_2/i_data_link_layer/s_ready_ser2
add wave -position insertpoint sim:/tb_serial_link/i_serial_link_2/i_data_link_layer/s_data_ser1b
add wave -position insertpoint sim:/tb_serial_link/i_serial_link_2/i_data_link_layer/s_valid_ser1b
add wave -position insertpoint sim:/tb_serial_link/i_serial_link_2/i_data_link_layer/s_ready_ser1b
add wave -position insertpoint sim:/tb_serial_link/i_serial_link_2/i_data_link_layer/s_data_ser1a
add wave -position insertpoint sim:/tb_serial_link/i_serial_link_2/i_data_link_layer/s_valid_ser1a
add wave -position insertpoint sim:/tb_serial_link/i_serial_link_2/i_data_link_layer/s_ready_ser1a
add wave -position insertpoint sim:/tb_serial_link/i_serial_link_2/s_d2n_data
add wave -position insertpoint sim:/tb_serial_link/i_serial_link_2/s_d2n_header
add wave -position insertpoint sim:/tb_serial_link/i_serial_link_2/s_d2n_valid
add wave -position insertpoint sim:/tb_serial_link/i_serial_link_2/s_d2n_ready

add wave -divider "2 to 1 pipeline"
add wave -position insertpoint sim:/tb_serial_link/i_serial_link_2/a_n2d_data
add wave -position insertpoint sim:/tb_serial_link/i_serial_link_2/a_n2d_header
add wave -position insertpoint sim:/tb_serial_link/i_serial_link_2/a_n2d_valid
add wave -position insertpoint sim:/tb_serial_link/i_serial_link_2/a_n2d_ready
add wave -position insertpoint sim:/tb_serial_link/i_serial_link_2/i_data_link_layer/a_data_ser1a
add wave -position insertpoint sim:/tb_serial_link/i_serial_link_2/i_data_link_layer/a_valid_ser1a
add wave -position insertpoint sim:/tb_serial_link/i_serial_link_2/i_data_link_layer/a_ready_ser1a
add wave -position insertpoint sim:/tb_serial_link/i_serial_link_2/i_data_link_layer/a_data_ser1b
add wave -position insertpoint sim:/tb_serial_link/i_serial_link_2/i_data_link_layer/a_valid_ser1b
add wave -position insertpoint sim:/tb_serial_link/i_serial_link_2/i_data_link_layer/a_ready_ser1b
add wave -position insertpoint sim:/tb_serial_link/i_serial_link_2/i_data_link_layer/a_data_ser2
add wave -position insertpoint sim:/tb_serial_link/i_serial_link_2/i_data_link_layer/a_valid_ser2
add wave -position insertpoint sim:/tb_serial_link/i_serial_link_2/i_data_link_layer/a_ready_ser2
add wave -position insertpoint sim:/tb_serial_link/i_serial_link_2/i_data_link_layer/a_data_ser3
add wave -position insertpoint sim:/tb_serial_link/i_serial_link_2/i_data_link_layer/a_valid_ser3
add wave -position insertpoint sim:/tb_serial_link/i_serial_link_2/i_data_link_layer/a_ready_ser3
add wave -position insertpoint sim:/tb_serial_link/i_serial_link_2/a_d2p_data
add wave -position insertpoint sim:/tb_serial_link/i_serial_link_1/i_phy_wrapper/i_synchronizer/correction_shift_q
add wave -position insertpoint sim:/tb_serial_link/i_serial_link_1/s_p2d_data
add wave -position insertpoint sim:/tb_serial_link/i_serial_link_1/i_data_link_layer/s_data_ser3
add wave -position insertpoint sim:/tb_serial_link/i_serial_link_1/i_data_link_layer/s_valid_ser3
add wave -position insertpoint sim:/tb_serial_link/i_serial_link_1/i_data_link_layer/s_ready_ser3
add wave -position insertpoint sim:/tb_serial_link/i_serial_link_1/i_data_link_layer/s_data_ser2
add wave -position insertpoint sim:/tb_serial_link/i_serial_link_1/i_data_link_layer/s_valid_ser2
add wave -position insertpoint sim:/tb_serial_link/i_serial_link_1/i_data_link_layer/s_ready_ser2
add wave -position insertpoint sim:/tb_serial_link/i_serial_link_1/i_data_link_layer/s_data_ser1b
add wave -position insertpoint sim:/tb_serial_link/i_serial_link_1/i_data_link_layer/s_valid_ser1b
add wave -position insertpoint sim:/tb_serial_link/i_serial_link_1/i_data_link_layer/s_ready_ser1b
add wave -position insertpoint sim:/tb_serial_link/i_serial_link_1/i_data_link_layer/s_data_ser1a
add wave -position insertpoint sim:/tb_serial_link/i_serial_link_1/i_data_link_layer/s_valid_ser1a
add wave -position insertpoint sim:/tb_serial_link/i_serial_link_1/i_data_link_layer/s_ready_ser1a
add wave -position insertpoint sim:/tb_serial_link/i_serial_link_1/s_d2n_data
add wave -position insertpoint sim:/tb_serial_link/i_serial_link_1/s_d2n_header
add wave -position insertpoint sim:/tb_serial_link/i_serial_link_1/s_d2n_valid
add wave -position insertpoint sim:/tb_serial_link/i_serial_link_1/s_d2n_ready

add wave -divider "CREDITS STUFF"
add wave -divider "1"
add wave -position insertpoint sim:/tb_serial_link/i_serial_link_1/i_data_link_layer/c_released
add wave -position insertpoint -radix decimal sim:/tb_serial_link/i_serial_link_1/i_data_link_layer/c_to_transmit
add wave -position insertpoint sim:/tb_serial_link/i_serial_link_1/i_data_link_layer/c_transmitted
add wave -position insertpoint -radix decimal sim:/tb_serial_link/i_serial_link_1/i_data_link_layer/c_received
add wave -position insertpoint -radix decimal sim:/tb_serial_link/i_serial_link_1/i_data_link_layer/c_avail
add wave -position insertpoint sim:/tb_serial_link/i_serial_link_1/i_data_link_layer/c_consumed
add wave -position insertpoint sim:/tb_serial_link/i_serial_link_1/i_data_link_layer/rx_fifo_full
add wave -divider "2"
add wave -position insertpoint sim:/tb_serial_link/i_serial_link_2/i_data_link_layer/c_released
add wave -position insertpoint -radix decimal sim:/tb_serial_link/i_serial_link_2/i_data_link_layer/c_to_transmit
add wave -position insertpoint sim:/tb_serial_link/i_serial_link_2/i_data_link_layer/c_transmitted
add wave -position insertpoint -radix decimal sim:/tb_serial_link/i_serial_link_2/i_data_link_layer/c_received
add wave -position insertpoint -radix decimal sim:/tb_serial_link/i_serial_link_2/i_data_link_layer/c_avail
add wave -position insertpoint sim:/tb_serial_link/i_serial_link_2/i_data_link_layer/c_consumed
add wave -position insertpoint sim:/tb_serial_link/i_serial_link_2/i_data_link_layer/rx_fifo_full

add wave -divider "Serializer 2"
add wave -position insertpoint sim:/tb_serial_link/i_serial_link_2/i_data_link_layer/i_serializer/*
add wave -divider "Deserializer 1"
add wave -position insertpoint sim:/tb_serial_link/i_serial_link_1/i_data_link_layer/i_deserializer/*
add wave -divider "Serializer 1"
add wave -position insertpoint sim:/tb_serial_link/i_serial_link_1/i_data_link_layer/i_serializer/*
add wave -divider "Deserializer 2"
add wave -position insertpoint sim:/tb_serial_link/i_serial_link_2/i_data_link_layer/i_deserializer/*

add wave -divider "Serial link instance 1"
add wave -position insertpoint sim:/tb_serial_link/i_serial_link_1/*

add wave -divider "Serial link instance 2"
add wave -position insertpoint sim:/tb_serial_link/i_serial_link_2/*

add wave -divider "TX controller 1"
add wave -position insertpoint sim:/tb_serial_link/i_serial_link_1/i_data_link_layer/i_tx_controller/*
add wave -divider "TX controller 2"
add wave -position insertpoint sim:/tb_serial_link/i_serial_link_2/i_data_link_layer/i_tx_controller/*
add wave -divider "RX controller 1"
add wave -position insertpoint sim:/tb_serial_link/i_serial_link_1/i_data_link_layer/i_rx_controller/*
add wave -divider "RX controller 2"
add wave -position insertpoint sim:/tb_serial_link/i_serial_link_2/i_data_link_layer/i_rx_controller/*

add wave -divider "Data link layer 2"
add wave -position insertpoint sim:/tb_serial_link/i_serial_link_2/i_data_link_layer/*

add wave -divider "NW layer 1"
add wave -position insertpoint sim:/tb_serial_link/i_serial_link_1/i_nw_layer/*

run 3ms


wave zoomfull