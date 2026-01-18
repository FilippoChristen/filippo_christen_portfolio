# This script was generated automatically by bender.
set ROOT "/home/sem25f9/Documents/low-power_axi_serial_link"

if {[catch { vlog -incr -sv \
    "+define+TARGET_SIMULATION" \
    "+define+TARGET_VSIM" \
    "$ROOT/.bender/git/checkouts/common_verification-b1c8c541a51da225/src/clk_rst_gen.sv" \
    "$ROOT/.bender/git/checkouts/common_verification-b1c8c541a51da225/src/sim_timeout.sv" \
    "$ROOT/.bender/git/checkouts/common_verification-b1c8c541a51da225/src/stream_watchdog.sv" \
    "$ROOT/.bender/git/checkouts/common_verification-b1c8c541a51da225/src/signal_highlighter.sv" \
}]} {return 1}

if {[catch { vlog -incr -sv \
    "+define+TARGET_SIMULATION" \
    "+define+TARGET_VSIM" \
    "$ROOT/.bender/git/checkouts/common_verification-b1c8c541a51da225/src/rand_id_queue.sv" \
    "$ROOT/.bender/git/checkouts/common_verification-b1c8c541a51da225/src/rand_stream_mst.sv" \
    "$ROOT/.bender/git/checkouts/common_verification-b1c8c541a51da225/src/rand_synch_holdable_driver.sv" \
    "$ROOT/.bender/git/checkouts/common_verification-b1c8c541a51da225/src/rand_verif_pkg.sv" \
    "$ROOT/.bender/git/checkouts/common_verification-b1c8c541a51da225/src/rand_synch_driver.sv" \
    "$ROOT/.bender/git/checkouts/common_verification-b1c8c541a51da225/src/rand_stream_slv.sv" \
}]} {return 1}

if {[catch { vlog -incr -sv \
    "+define+TARGET_SIMULATION" \
    "+define+TARGET_VSIM" \
    "$ROOT/.bender/git/checkouts/tech_cells_generic-953575365fb850e1/src/rtl/tc_sram.sv" \
    "$ROOT/.bender/git/checkouts/tech_cells_generic-953575365fb850e1/src/rtl/tc_sram_impl.sv" \
}]} {return 1}

if {[catch { vlog -incr -sv \
    "+define+TARGET_SIMULATION" \
    "+define+TARGET_VSIM" \
    "$ROOT/.bender/git/checkouts/tech_cells_generic-953575365fb850e1/src/rtl/tc_clk.sv" \
}]} {return 1}

if {[catch { vlog -incr -sv \
    "+define+TARGET_SIMULATION" \
    "+define+TARGET_VSIM" \
    "$ROOT/.bender/git/checkouts/tech_cells_generic-953575365fb850e1/src/deprecated/cluster_pwr_cells.sv" \
    "$ROOT/.bender/git/checkouts/tech_cells_generic-953575365fb850e1/src/deprecated/generic_memory.sv" \
    "$ROOT/.bender/git/checkouts/tech_cells_generic-953575365fb850e1/src/deprecated/generic_rom.sv" \
    "$ROOT/.bender/git/checkouts/tech_cells_generic-953575365fb850e1/src/deprecated/pad_functional.sv" \
    "$ROOT/.bender/git/checkouts/tech_cells_generic-953575365fb850e1/src/deprecated/pulp_buffer.sv" \
    "$ROOT/.bender/git/checkouts/tech_cells_generic-953575365fb850e1/src/deprecated/pulp_pwr_cells.sv" \
}]} {return 1}

if {[catch { vlog -incr -sv \
    "+define+TARGET_SIMULATION" \
    "+define+TARGET_VSIM" \
    "$ROOT/.bender/git/checkouts/tech_cells_generic-953575365fb850e1/src/tc_pwr.sv" \
}]} {return 1}

if {[catch { vlog -incr -sv \
    "+define+TARGET_SIMULATION" \
    "+define+TARGET_VSIM" \
    "$ROOT/.bender/git/checkouts/tech_cells_generic-953575365fb850e1/src/deprecated/pulp_clock_gating_async.sv" \
    "$ROOT/.bender/git/checkouts/tech_cells_generic-953575365fb850e1/src/deprecated/cluster_clk_cells.sv" \
    "$ROOT/.bender/git/checkouts/tech_cells_generic-953575365fb850e1/src/deprecated/pulp_clk_cells.sv" \
}]} {return 1}

if {[catch { vlog -incr -sv \
    "+define+TARGET_SIMULATION" \
    "+define+TARGET_VSIM" \
    "+incdir+$ROOT/.bender/git/checkouts/common_cells-86afb8807bd1553e/include" \
    "$ROOT/.bender/git/checkouts/common_cells-86afb8807bd1553e/src/binary_to_gray.sv" \
}]} {return 1}

if {[catch { vlog -incr -sv \
    "+define+TARGET_SIMULATION" \
    "+define+TARGET_VSIM" \
    "+incdir+$ROOT/.bender/git/checkouts/common_cells-86afb8807bd1553e/include" \
    "$ROOT/.bender/git/checkouts/common_cells-86afb8807bd1553e/src/cb_filter_pkg.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-86afb8807bd1553e/src/cc_onehot.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-86afb8807bd1553e/src/cdc_reset_ctrlr_pkg.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-86afb8807bd1553e/src/cf_math_pkg.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-86afb8807bd1553e/src/clk_int_div.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-86afb8807bd1553e/src/credit_counter.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-86afb8807bd1553e/src/delta_counter.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-86afb8807bd1553e/src/ecc_pkg.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-86afb8807bd1553e/src/edge_propagator_tx.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-86afb8807bd1553e/src/exp_backoff.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-86afb8807bd1553e/src/fifo_v3.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-86afb8807bd1553e/src/gray_to_binary.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-86afb8807bd1553e/src/isochronous_4phase_handshake.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-86afb8807bd1553e/src/isochronous_spill_register.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-86afb8807bd1553e/src/lfsr.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-86afb8807bd1553e/src/lfsr_16bit.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-86afb8807bd1553e/src/lfsr_8bit.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-86afb8807bd1553e/src/lossy_valid_to_stream.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-86afb8807bd1553e/src/mv_filter.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-86afb8807bd1553e/src/onehot_to_bin.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-86afb8807bd1553e/src/plru_tree.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-86afb8807bd1553e/src/passthrough_stream_fifo.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-86afb8807bd1553e/src/popcount.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-86afb8807bd1553e/src/rr_arb_tree.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-86afb8807bd1553e/src/rstgen_bypass.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-86afb8807bd1553e/src/serial_deglitch.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-86afb8807bd1553e/src/shift_reg.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-86afb8807bd1553e/src/shift_reg_gated.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-86afb8807bd1553e/src/spill_register_flushable.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-86afb8807bd1553e/src/stream_demux.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-86afb8807bd1553e/src/stream_filter.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-86afb8807bd1553e/src/stream_fork.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-86afb8807bd1553e/src/stream_intf.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-86afb8807bd1553e/src/stream_join_dynamic.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-86afb8807bd1553e/src/stream_mux.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-86afb8807bd1553e/src/stream_throttle.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-86afb8807bd1553e/src/sub_per_hash.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-86afb8807bd1553e/src/sync.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-86afb8807bd1553e/src/sync_wedge.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-86afb8807bd1553e/src/unread.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-86afb8807bd1553e/src/read.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-86afb8807bd1553e/src/addr_decode_dync.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-86afb8807bd1553e/src/cdc_2phase.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-86afb8807bd1553e/src/cdc_4phase.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-86afb8807bd1553e/src/clk_int_div_static.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-86afb8807bd1553e/src/addr_decode.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-86afb8807bd1553e/src/addr_decode_napot.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-86afb8807bd1553e/src/multiaddr_decode.sv" \
}]} {return 1}

if {[catch { vlog -incr -sv \
    "+define+TARGET_SIMULATION" \
    "+define+TARGET_VSIM" \
    "+incdir+$ROOT/.bender/git/checkouts/common_cells-86afb8807bd1553e/include" \
    "$ROOT/.bender/git/checkouts/common_cells-86afb8807bd1553e/src/cb_filter.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-86afb8807bd1553e/src/cdc_fifo_2phase.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-86afb8807bd1553e/src/clk_mux_glitch_free.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-86afb8807bd1553e/src/counter.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-86afb8807bd1553e/src/ecc_decode.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-86afb8807bd1553e/src/ecc_encode.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-86afb8807bd1553e/src/edge_detect.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-86afb8807bd1553e/src/lzc.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-86afb8807bd1553e/src/max_counter.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-86afb8807bd1553e/src/rstgen.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-86afb8807bd1553e/src/spill_register.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-86afb8807bd1553e/src/stream_delay.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-86afb8807bd1553e/src/stream_fifo.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-86afb8807bd1553e/src/stream_fork_dynamic.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-86afb8807bd1553e/src/stream_join.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-86afb8807bd1553e/src/cdc_reset_ctrlr.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-86afb8807bd1553e/src/cdc_fifo_gray.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-86afb8807bd1553e/src/fall_through_register.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-86afb8807bd1553e/src/id_queue.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-86afb8807bd1553e/src/stream_to_mem.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-86afb8807bd1553e/src/stream_arbiter_flushable.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-86afb8807bd1553e/src/stream_fifo_optimal_wrap.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-86afb8807bd1553e/src/stream_register.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-86afb8807bd1553e/src/stream_xbar.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-86afb8807bd1553e/src/cdc_fifo_gray_clearable.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-86afb8807bd1553e/src/cdc_2phase_clearable.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-86afb8807bd1553e/src/mem_to_banks_detailed.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-86afb8807bd1553e/src/stream_arbiter.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-86afb8807bd1553e/src/stream_omega_net.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-86afb8807bd1553e/src/mem_to_banks.sv" \
}]} {return 1}

if {[catch { vlog -incr -sv \
    "+define+TARGET_SIMULATION" \
    "+define+TARGET_VSIM" \
    "+incdir+$ROOT/.bender/git/checkouts/common_cells-86afb8807bd1553e/include" \
    "$ROOT/.bender/git/checkouts/common_cells-86afb8807bd1553e/src/deprecated/sram.sv" \
}]} {return 1}

if {[catch { vlog -incr -sv \
    "+define+TARGET_SIMULATION" \
    "+define+TARGET_VSIM" \
    "+incdir+$ROOT/.bender/git/checkouts/common_cells-86afb8807bd1553e/include" \
    "$ROOT/.bender/git/checkouts/common_cells-86afb8807bd1553e/src/deprecated/clock_divider_counter.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-86afb8807bd1553e/src/deprecated/clk_div.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-86afb8807bd1553e/src/deprecated/find_first_one.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-86afb8807bd1553e/src/deprecated/generic_LFSR_8bit.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-86afb8807bd1553e/src/deprecated/generic_fifo.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-86afb8807bd1553e/src/deprecated/prioarbiter.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-86afb8807bd1553e/src/deprecated/pulp_sync.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-86afb8807bd1553e/src/deprecated/pulp_sync_wedge.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-86afb8807bd1553e/src/deprecated/rrarbiter.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-86afb8807bd1553e/src/deprecated/clock_divider.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-86afb8807bd1553e/src/deprecated/fifo_v2.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-86afb8807bd1553e/src/deprecated/fifo_v1.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-86afb8807bd1553e/src/edge_propagator_ack.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-86afb8807bd1553e/src/edge_propagator.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-86afb8807bd1553e/src/edge_propagator_rx.sv" \
}]} {return 1}

if {[catch { vlog -incr -sv \
    "+define+TARGET_SIMULATION" \
    "+define+TARGET_VSIM" \
    "+incdir+$ROOT/.bender/git/checkouts/apb-2c6adb6ce5d5d033/include" \
    "+incdir+$ROOT/.bender/git/checkouts/common_cells-86afb8807bd1553e/include" \
    "$ROOT/.bender/git/checkouts/apb-2c6adb6ce5d5d033/src/apb_pkg.sv" \
    "$ROOT/.bender/git/checkouts/apb-2c6adb6ce5d5d033/src/apb_intf.sv" \
    "$ROOT/.bender/git/checkouts/apb-2c6adb6ce5d5d033/src/apb_err_slv.sv" \
    "$ROOT/.bender/git/checkouts/apb-2c6adb6ce5d5d033/src/apb_regs.sv" \
    "$ROOT/.bender/git/checkouts/apb-2c6adb6ce5d5d033/src/apb_cdc.sv" \
    "$ROOT/.bender/git/checkouts/apb-2c6adb6ce5d5d033/src/apb_demux.sv" \
}]} {return 1}

if {[catch { vlog -incr -sv \
    "+define+TARGET_SIMULATION" \
    "+define+TARGET_VSIM" \
    "+incdir+$ROOT/.bender/git/checkouts/apb-2c6adb6ce5d5d033/include" \
    "+incdir+$ROOT/.bender/git/checkouts/common_cells-86afb8807bd1553e/include" \
    "$ROOT/.bender/git/checkouts/apb-2c6adb6ce5d5d033/src/apb_test.sv" \
}]} {return 1}

if {[catch { vlog -incr -sv \
    "+define+TARGET_SIMULATION" \
    "+define+TARGET_VSIM" \
    "+incdir+$ROOT/.bender/git/checkouts/axi-31ed4bb6f90eb937/include" \
    "+incdir+$ROOT/.bender/git/checkouts/common_cells-86afb8807bd1553e/include" \
    "$ROOT/.bender/git/checkouts/axi-31ed4bb6f90eb937/src/axi_pkg.sv" \
    "$ROOT/.bender/git/checkouts/axi-31ed4bb6f90eb937/src/axi_intf.sv" \
    "$ROOT/.bender/git/checkouts/axi-31ed4bb6f90eb937/src/axi_atop_filter.sv" \
    "$ROOT/.bender/git/checkouts/axi-31ed4bb6f90eb937/src/axi_burst_splitter.sv" \
    "$ROOT/.bender/git/checkouts/axi-31ed4bb6f90eb937/src/axi_cdc_dst.sv" \
    "$ROOT/.bender/git/checkouts/axi-31ed4bb6f90eb937/src/axi_cdc_src.sv" \
    "$ROOT/.bender/git/checkouts/axi-31ed4bb6f90eb937/src/axi_cut.sv" \
    "$ROOT/.bender/git/checkouts/axi-31ed4bb6f90eb937/src/axi_delayer.sv" \
    "$ROOT/.bender/git/checkouts/axi-31ed4bb6f90eb937/src/axi_demux.sv" \
    "$ROOT/.bender/git/checkouts/axi-31ed4bb6f90eb937/src/axi_dw_downsizer.sv" \
    "$ROOT/.bender/git/checkouts/axi-31ed4bb6f90eb937/src/axi_dw_upsizer.sv" \
    "$ROOT/.bender/git/checkouts/axi-31ed4bb6f90eb937/src/axi_fifo.sv" \
    "$ROOT/.bender/git/checkouts/axi-31ed4bb6f90eb937/src/axi_id_remap.sv" \
    "$ROOT/.bender/git/checkouts/axi-31ed4bb6f90eb937/src/axi_id_prepend.sv" \
    "$ROOT/.bender/git/checkouts/axi-31ed4bb6f90eb937/src/axi_isolate.sv" \
    "$ROOT/.bender/git/checkouts/axi-31ed4bb6f90eb937/src/axi_join.sv" \
    "$ROOT/.bender/git/checkouts/axi-31ed4bb6f90eb937/src/axi_lite_demux.sv" \
    "$ROOT/.bender/git/checkouts/axi-31ed4bb6f90eb937/src/axi_lite_join.sv" \
    "$ROOT/.bender/git/checkouts/axi-31ed4bb6f90eb937/src/axi_lite_lfsr.sv" \
    "$ROOT/.bender/git/checkouts/axi-31ed4bb6f90eb937/src/axi_lite_mailbox.sv" \
    "$ROOT/.bender/git/checkouts/axi-31ed4bb6f90eb937/src/axi_lite_mux.sv" \
    "$ROOT/.bender/git/checkouts/axi-31ed4bb6f90eb937/src/axi_lite_regs.sv" \
    "$ROOT/.bender/git/checkouts/axi-31ed4bb6f90eb937/src/axi_lite_to_apb.sv" \
    "$ROOT/.bender/git/checkouts/axi-31ed4bb6f90eb937/src/axi_lite_to_axi.sv" \
    "$ROOT/.bender/git/checkouts/axi-31ed4bb6f90eb937/src/axi_modify_address.sv" \
    "$ROOT/.bender/git/checkouts/axi-31ed4bb6f90eb937/src/axi_mux.sv" \
    "$ROOT/.bender/git/checkouts/axi-31ed4bb6f90eb937/src/axi_serializer.sv" \
    "$ROOT/.bender/git/checkouts/axi-31ed4bb6f90eb937/src/axi_throttle.sv" \
    "$ROOT/.bender/git/checkouts/axi-31ed4bb6f90eb937/src/axi_to_mem.sv" \
    "$ROOT/.bender/git/checkouts/axi-31ed4bb6f90eb937/src/axi_cdc.sv" \
    "$ROOT/.bender/git/checkouts/axi-31ed4bb6f90eb937/src/axi_err_slv.sv" \
    "$ROOT/.bender/git/checkouts/axi-31ed4bb6f90eb937/src/axi_dw_converter.sv" \
    "$ROOT/.bender/git/checkouts/axi-31ed4bb6f90eb937/src/axi_id_serialize.sv" \
    "$ROOT/.bender/git/checkouts/axi-31ed4bb6f90eb937/src/axi_lfsr.sv" \
    "$ROOT/.bender/git/checkouts/axi-31ed4bb6f90eb937/src/axi_multicut.sv" \
    "$ROOT/.bender/git/checkouts/axi-31ed4bb6f90eb937/src/axi_to_axi_lite.sv" \
    "$ROOT/.bender/git/checkouts/axi-31ed4bb6f90eb937/src/axi_to_mem_banked.sv" \
    "$ROOT/.bender/git/checkouts/axi-31ed4bb6f90eb937/src/axi_to_mem_interleaved.sv" \
    "$ROOT/.bender/git/checkouts/axi-31ed4bb6f90eb937/src/axi_to_mem_split.sv" \
    "$ROOT/.bender/git/checkouts/axi-31ed4bb6f90eb937/src/axi_iw_converter.sv" \
    "$ROOT/.bender/git/checkouts/axi-31ed4bb6f90eb937/src/axi_lite_xbar.sv" \
    "$ROOT/.bender/git/checkouts/axi-31ed4bb6f90eb937/src/axi_xbar.sv" \
    "$ROOT/.bender/git/checkouts/axi-31ed4bb6f90eb937/src/axi_xp.sv" \
}]} {return 1}

if {[catch { vlog -incr -sv \
    "+define+TARGET_SIMULATION" \
    "+define+TARGET_VSIM" \
    "+incdir+$ROOT/.bender/git/checkouts/axi-31ed4bb6f90eb937/include" \
    "+incdir+$ROOT/.bender/git/checkouts/common_cells-86afb8807bd1553e/include" \
    "$ROOT/.bender/git/checkouts/axi-31ed4bb6f90eb937/src/axi_dumper.sv" \
    "$ROOT/.bender/git/checkouts/axi-31ed4bb6f90eb937/src/axi_sim_mem.sv" \
    "$ROOT/.bender/git/checkouts/axi-31ed4bb6f90eb937/src/axi_test.sv" \
}]} {return 1}

if {[catch { vlog -incr -sv \
    "+define+TARGET_SIMULATION" \
    "+define+TARGET_VSIM" \
    "+incdir+$ROOT/.bender/git/checkouts/apb-2c6adb6ce5d5d033/include" \
    "+incdir+$ROOT/.bender/git/checkouts/axi-31ed4bb6f90eb937/include" \
    "+incdir+$ROOT/.bender/git/checkouts/common_cells-86afb8807bd1553e/include" \
    "+incdir+$ROOT/.bender/git/checkouts/register_interface-f195d97effd86592/include" \
    "$ROOT/.bender/git/checkouts/register_interface-f195d97effd86592/src/reg_intf.sv" \
    "$ROOT/.bender/git/checkouts/register_interface-f195d97effd86592/vendor/lowrisc_opentitan/src/prim_subreg_arb.sv" \
    "$ROOT/.bender/git/checkouts/register_interface-f195d97effd86592/vendor/lowrisc_opentitan/src/prim_subreg_ext.sv" \
    "$ROOT/.bender/git/checkouts/register_interface-f195d97effd86592/src/apb_to_reg.sv" \
    "$ROOT/.bender/git/checkouts/register_interface-f195d97effd86592/src/axi_to_reg.sv" \
    "$ROOT/.bender/git/checkouts/register_interface-f195d97effd86592/src/periph_to_reg.sv" \
    "$ROOT/.bender/git/checkouts/register_interface-f195d97effd86592/src/reg_cdc.sv" \
    "$ROOT/.bender/git/checkouts/register_interface-f195d97effd86592/src/reg_demux.sv" \
    "$ROOT/.bender/git/checkouts/register_interface-f195d97effd86592/src/reg_err_slv.sv" \
    "$ROOT/.bender/git/checkouts/register_interface-f195d97effd86592/src/reg_mux.sv" \
    "$ROOT/.bender/git/checkouts/register_interface-f195d97effd86592/src/reg_to_apb.sv" \
    "$ROOT/.bender/git/checkouts/register_interface-f195d97effd86592/src/reg_to_mem.sv" \
    "$ROOT/.bender/git/checkouts/register_interface-f195d97effd86592/src/reg_uniform.sv" \
    "$ROOT/.bender/git/checkouts/register_interface-f195d97effd86592/src/reg_to_tlul.sv" \
    "$ROOT/.bender/git/checkouts/register_interface-f195d97effd86592/vendor/lowrisc_opentitan/src/prim_subreg_shadow.sv" \
    "$ROOT/.bender/git/checkouts/register_interface-f195d97effd86592/vendor/lowrisc_opentitan/src/prim_subreg.sv" \
    "$ROOT/.bender/git/checkouts/register_interface-f195d97effd86592/src/axi_lite_to_reg.sv" \
}]} {return 1}

if {[catch { vlog -incr -sv \
    "+define+TARGET_SIMULATION" \
    "+define+TARGET_VSIM" \
    "+incdir+$ROOT/.bender/git/checkouts/axi-31ed4bb6f90eb937/include" \
    "+incdir+$ROOT/.bender/git/checkouts/common_cells-86afb8807bd1553e/include" \
    "+incdir+$ROOT/.bender/git/checkouts/register_interface-f195d97effd86592/include" \
    "+incdir+$ROOT/src/axis/include" \
    "$ROOT/src/phy/src/Deskewer_Circuit_SAR_newdel_2004/Deskew.v" \
    "$ROOT/src/phy/src/Deskewer_Circuit_SAR_newdel_2004/PLL_HARDWAR_deskew.v" \
    "$ROOT/src/phy/src/Deskewer_Circuit_SAR_newdel_2004/LoopFilter_5b_deskew.v" \
    "$ROOT/src/phy/src/Deskewer_Circuit_SAR_newdel_2004/DCO_Controller_deskew.v" \
    "$ROOT/src/phy/src/Deskewer_Circuit_SAR_newdel_2004/DCO_Controller_deskew_3bit.v" \
    "$ROOT/src/phy/src/Deskewer_FWDCLK_quarterrate_sar_newdely_2004/VCDL.v" \
    "$ROOT/src/phy/src/Deskewer_FWDCLK_quarterrate_sar_newdely_2004/Deskewer.v" \
    "$ROOT/src/phy/src/Deskewer_FWDCLK_quarterrate_sar_newdely_2004/Alexander.v" \
    "$ROOT/src/phy/src/Deskewer_FWDCLK_quarterrate_sar_newdely_2004/vdelay.v" \
    "$ROOT/src/phy/src/DigitalDLL_new_lf170425_duty_synth/PLL_Wrapper_dll.v" \
    "$ROOT/src/phy/src/DigitalDLL_new_lf170425_duty_synth/PLL_HARDWARE_dll.v" \
    "$ROOT/src/phy/src/DigitalDLL_new_lf170425_duty_synth/LoopFilter_dll.v" \
    "$ROOT/src/phy/src/DigitalDLL_new_lf170425_duty_synth/DCO_Controller_dll.v" \
    "$ROOT/src/phy/src/DigitalDLL_QuarterRate_post_DEBUG-1904/DigDel.v" \
    "$ROOT/src/phy/src/DigitalDLL_QuarterRate_post_DEBUG-1904/DigDLL.v" \
    "$ROOT/src/phy/src/DigitalDLL_QuarterRate_post_DEBUG-1904/BBPFD_dll.v" \
    "$ROOT/src/phy/src/DigitalDLL_QuarterRate_post_DEBUG-1904/vdelay_dll.v" \
    "$ROOT/src/phy/src/SeriallinkModel2904/RX_CLK_GEN.v" \
    "$ROOT/src/phy/src/SeriallinkModel2904/MUX8_1_JItter.v" \
    "$ROOT/src/phy/src/SeriallinkModel2904/DEMUX1_8.v" \
    "$ROOT/src/phy/src/SeriallinkModel2904/CLK_GEN.sv" \
    "$ROOT/src/phy/src/SeriallinkModel2904/PN31.v" \
    "$ROOT/src/phy_wrapper/phy_wrapper.sv" \
    "$ROOT/src/phy_wrapper/synchronizer.sv" \
    "$ROOT/src/nw_layer/nw_layer.sv" \
    "$ROOT/src/data_layer/rx_controller.sv" \
    "$ROOT/src/data_layer/tx_controller.sv" \
    "$ROOT/src/data_layer/serializer.sv" \
    "$ROOT/src/data_layer/deserializer.sv" \
    "$ROOT/src/data_layer/raw_mode_ctrl.sv" \
    "$ROOT/src/data_layer/data_link_layer.sv" \
    "$ROOT/src/serial_link.sv" \
    "$ROOT/src/utils/clock_shifter.sv" \
    "$ROOT/test/axi_chan_compare.sv" \
    "$ROOT/test/tb_serial_link.sv" \
}]} {return 1}

