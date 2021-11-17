#LANG = verilog
LANG = vhdl

WPWD = $(CURDIR)
PYTHONPATH=$(WPWD):$(PYTHONTPATH)
ifeq (${LANG}, verilog)
SIM = icarus
VERILOG_SOURCES =  ${WPWD}/../hdl/axi_spi.v \
                   ${WPWD}/../hdl/spi.v \
                   ${WPWD}/../hdl/axi_lite_slave_int.v
endif

ifeq (${LANG}, vhdl)
SIM = ghdl
SIM_ARGS = --wave=axi_spi.ghw --ieee-asserts=disable-at-0
VHDL_SOURCES = ${WPWD}/../hdl/spi.vhdl \
               ${WPWD}/../hdl/axi_lite_slave_int.vhdl \
               ${WPWD}/../hdl/axi_spi.vhdl
endif

export COCOTB_REDUCED_LOG_FMT = true

TOPLEVEL = axi_spi
MODULE = spi_test
include $(COCOTB)/makefiles/Makefile.inc
include $(COCOTB)/makefiles/Makefile.sim
