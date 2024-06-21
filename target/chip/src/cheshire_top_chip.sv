// Copyright 2023 ETH Zurich and University of Bologna.
// Solderpad Hardware License, Version 0.51, see LICENSE for details.
// SPDX-License-Identifier: SHL-0.51
//
// Nicole Narr <narrn@student.ethz.ch>
// Christopher Reinwardt <creinwar@student.ethz.ch>
// Cyril Koenig <cykoenig@iis.ee.ethz.ch>
// Yann Picod <ypicod@ethz.ch>
// Paul Scheffler <paulsc@iis.ee.ethz.ch>

`include "cheshire/typedef.svh"

// TODO: Expose more IO: unused SPI CS, Serial Link, etc.

import cheshire_pkg::*;

// Use default config as far as possible
function automatic cheshire_cfg_t gen_cheshire_chip_cfg();
   cheshire_cfg_t ret  = DefaultCfg;
   ret.Vga = 0;
   ret.AxiDataWidth = 32;
   ret.AddrWidth = 32;
   ret.LlcOutRegionEnd = 'hFFFF_FFFF;
   ret.SerialLink      = 0;
   return ret;
endfunction

// Configure cheshire for FPGA mapping

module cheshire_top_chip #(
  // Cheshire config
  parameter cheshire_cfg_t ChipCfg = gen_cheshire_chip_cfg(),
) (
  input  logic        clk_i,
  input  logic        rst_ni,
  input  logic        test_mode_i,
  input  logic [1:0]  boot_mode_i,
  input  logic        rtc_i,
  // JTAG interface
  input  logic  jtag_tck_i,
  input  logic  jtag_trst_ni,
  input  logic  jtag_tms_i,
  input  logic  jtag_tdi_i,
  output logic  jtag_tdo_o,
  output logic  jtag_tdo_oe_o,
  // UART interface
  output logic  uart_tx_o,
  input  logic  uart_rx_i,
  // UART modem flow control
  output logic  uart_rts_no,
  output logic  uart_dtr_no,
  input  logic  uart_cts_ni,
  input  logic  uart_dsr_ni,
  input  logic  uart_dcd_ni,
  input  logic  uart_rin_ni,
  // I2C interface
  output logic  i2c_sda_o,
  input  logic  i2c_sda_i,
  output logic  i2c_sda_en_o,
  output logic  i2c_scl_o,
  input  logic  i2c_scl_i,
  output logic  i2c_scl_en_o,
  // SPI host interface
  output logic                  spih_sck_o,
  output logic                  spih_sck_en_o,
  output logic [SpihNumCs-1:0]  spih_csb_o,
  output logic [SpihNumCs-1:0]  spih_csb_en_o,
  output logic [ 3:0]           spih_sd_o,
  output logic [ 3:0]           spih_sd_en_o,
  input  logic [ 3:0]           spih_sd_i,
  // GPIO interface
  input  logic [31:0] gpio_i,
  output logic [31:0] gpio_o,
  output logic [31:0] gpio_en_o,
  // Serial link interface
  input  logic [SlinkNumChan-1:0]                     slink_rcv_clk_i,
  output logic [SlinkNumChan-1:0]                     slink_rcv_clk_o,
  input  logic [SlinkNumChan-1:0][SlinkNumLanes-1:0]  slink_i,
  output logic [SlinkNumChan-1:0][SlinkNumLanes-1:0]  slink_o,
  // VGA interface
  output logic                          vga_hsync_o,
  output logic                          vga_vsync_o,
  output logic [ChipCfg.VgaRedWidth  -1:0]  vga_red_o,
  output logic [ChipCfg.VgaGreenWidth-1:0]  vga_green_o,
  output logic [ChipCfg.VgaBlueWidth -1:0]  vga_blue_o
);

  ///////////////////////
  //  Cheshire Config  //
  ///////////////////////
                          
   `CHESHIRE_TYPEDEF_ALL(, ChipCfg)
   
  //////////////////
  // Cheshire SoC //
  //////////////////

  cheshire_soc #(
    .Cfg                ( ChipCfg ),
    .ExtHartinfo        ( '0 ),
    .axi_ext_llc_req_t  ( axi_llc_req_t ),
    .axi_ext_llc_rsp_t  ( axi_llc_rsp_t ),
    .axi_ext_mst_req_t  ( axi_mst_req_t ),
    .axi_ext_mst_rsp_t  ( axi_mst_rsp_t ),
    .axi_ext_slv_req_t  ( axi_slv_req_t ),
    .axi_ext_slv_rsp_t  ( axi_slv_rsp_t ),
    .reg_ext_req_t      ( reg_req_t ),
    .reg_ext_rsp_t      ( reg_req_t )
  ) i_cheshire_soc (
   .clk_i,
   .rst_ni,
   .test_mode_i,
   .boot_mode_i,
   .rtc_i,
   // External AXI LLC (DRAM) port
   .axi_llc_mst_rsp_i('0),
   // External AXI crossbar ports
   .axi_ext_mst_req_i('0),
   .axi_ext_slv_rsp_i('0),
   // External reg demux slaves
   .reg_ext_slv_rsp_i('0),
   // Interrupts from and to external targets
   .intr_ext_i('0),
   .dbg_ext_unavail_i('0),
   // JTAG interface
   .jtag_tck_i,
   .jtag_trst_ni,
   .jtag_tms_i,
   .jtag_tdi_i,
   .jtag_tdo_o,
   .jtag_tdo_oe_o,
   // UART interface
   .uart_tx_o,
   .uart_rx_i,
   // UART modem flow control
   .uart_rts_no,
   .uart_dtr_no,
   .uart_cts_ni,
   .uart_dsr_ni,
   .uart_dcd_ni,
   .uart_rin_ni,
   // I2C interface
   .i2c_sda_o,
   .i2c_sda_i,
   .i2c_sda_en_o,
   .i2c_scl_o,
   .i2c_scl_i,
   .i2c_scl_en_o,
   // SPI host interface
   .spih_sck_o,
   .spih_sck_en_o,
   .spih_csb_o,
   .spih_csb_en_o,
   .spih_sd_o,
   .spih_sd_en_o,
   .spih_sd_i,
   // GPIO interface
   .gpio_i,
   .gpio_o,
   .gpio_en_o,
   // Serial link interface
   .slink_rcv_clk_i,
   .slink_rcv_clk_o,
   .slink_i,
   .slink_o,
   // VGA interface
   .vga_hsync_o,
   .vga_vsync_o,
   .vga_red_o,
   .vga_green_o,
   .vga_blue_o
  );

endmodule
