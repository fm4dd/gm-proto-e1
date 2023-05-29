## config.mk

EXE =

## toolchain
YOSYS = /home/fm/cc-toolchain-linux/bin/yosys/yosys$(EXE)
PR    = /home/fm/cc-toolchain-linux/bin/p_r/p_r$(EXE)
OFL   = /usr/local/bin/openFPGALoader$(EXE)

## latest GTKwave v3.4.0 is here:
GTKW = /usr/share/gtkwave/gtkwave3-gtk3/src/gtkwave
IVL = iverilog
VVP = vvp
IVLFLAGS = -Winfloop -g2012 -gspecify -Ttyp

## simulation libraries
CELLS_SYNTH = /home/fm/cc-toolchain-linux/bin/yosys/share/gatemate/cells_sim.v
CELLS_IMPL = /home/fm/cc-toolchain-linux/bin/p_r/cpelib.v

## target sources
VLOG_SRC = $(shell find ./src/ -type f \( -iname \*.v -o -iname \*.sv \))
VHDL_SRC = $(shell find ./src/ -type f \( -iname \*.vhd -o -iname \*.vhdl \))

## misc tools
RM = rm -rf

## toolchain targets
synth: synth_vlog

synth_vlog: $(VLOG_SRC)
	@test -d log || mkdir log
	@test -d net || mkdir net
	$(YOSYS) -ql log/synth.log -p 'read -sv $^; synth_gatemate -top $(TOP) -nomx8 -vlog net/$(TOP)_synth.v'

synth_vhdl: $(VHDL_SRC)
	@test -d log || mkdir log
	@test -d net || mkdir net
	$(YOSYS) -ql log/synth.log -p 'ghdl --warn-no-binding -C --ieee=synopsys $^ -e $(TOP); synth_gatemate -top $(TOP) -vlog net/$(TOP)_synth.v'

impl:
	$(PR) -i net/$(TOP)_synth.v -o $(TOP) $(PRFLAGS) > log/$@.log

jtag:
	$(OFL) $(OFLFLAGS) -b gatemate_evb_jtag $(TOP)_00.cfg

jtag-flash:
	$(OFL) $(OFLFLAGS) -b gatemate_evb_jtag -f --verify $(TOP)_00.cfg

spi:
	$(OFL) $(OFLFLAGS) -b gatemate_evb_spi -m $(TOP)_00.cfg

spi-flash:
	$(OFL) $(OFLFLAGS) -b gatemate_evb_spi -f --verify $(TOP)_00.cfg

# /usr/bin/iverilog -o sim/pmod_charlcd.tb -s pmod_charlcd_tb sim/*.v src/*.v
test:
	@echo 'Creating testbench file'
	test ! -e sim/$(TOP).tb || rm sim/$(TOP).tb
	test ! -e $(TOP).vcd || rm $(TOP).vcd
	$(IVL) -o sim/$(TOP).tb -s $(TOP)_tb $(VLOG_SRC) sim/$(TOP)_tb.v
	@echo 'Running testbench simulation'
	$(VVP) sim/$(TOP).tb
	$(GTKW) $(TOP).vcd sim/config.gtkw

all: synth impl jtag

## verilog simulation targets
vlog_sim.vvp:
	$(IVL) $(IVLFLAGS) -o sim/$@ $(VLOG_SRC) sim/$(TOP)_tb.v

synth_sim.vvp:
	$(IVL) $(IVLFLAGS) -o sim/$@ net/$(TOP)_synth.v sim/$(TOP)_tb.v $(CELLS_SYNTH)

impl_sim.vvp:
	$(IVL) $(IVLFLAGS) -o sim/$@ $(TOP)_00.v sim/$(TOP)_tb.v $(CELLS_IMPL)

.PHONY: %sim %sim.vvp
%sim: %sim.vvp
	$(VVP) -N sim/$< -lx2
	@$(RM) sim/$^

wave:
	$(GTKW) $(TOP).vcd sim/config.gtkw

clean:
	$(RM) log/*.log
	$(RM) net/*_synth.v
	$(RM) *.history
	$(RM) *.txt
	$(RM) *.refwire
	$(RM) *.refparam
	$(RM) *.refcomp
	$(RM) *.pos
	$(RM) *.pathes
	$(RM) *.path_struc
	$(RM) *.net
	$(RM) *.id
	$(RM) *.prn
	$(RM) *_00.v
	$(RM) *.used
	$(RM) *.sdf
	$(RM) *.place
	$(RM) *.pin
	$(RM) *.cfg*
	$(RM) *.cdf
	$(RM) sim/*.vcd
	$(RM) sim/*.vvp
	$(RM) sim/*.gtkw
	test ! -d log || rmdir log
	test ! -d net || rmdir net

