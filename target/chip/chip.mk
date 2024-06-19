SYNOPSYS ?= synopsys-2022.03 dc_shell

CHS_CHIP_DIR ?= $(CHS_ROOT)/target/chip

$(CHS_CHIP_DIR)/ic/:
	mkdir -p $@
	cd $@ && icdesign tsmc65 -nogui && cd $(CHS_ROOT)

#ic_design tsmc65 -update all

#i$(CHS_CHIP_DIR)/synopsys/: $(SYNOPSYS)

$(CHS_CHIP_DIR)/scripts/analyze_chip.tcl: $(CHS_CHIP_DIR)/ic/
	bender script synopsys -t asic -t cv32a6_convolve -t cva6 > $@

CHS_CHIP_ALL = $$(CHS_CHIP_DIR)/scripts/analyze_chip.tcl
