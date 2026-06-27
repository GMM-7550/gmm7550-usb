TEST ?= SyncOnly

DUT := bs_nrzi
TB := $(DUT)_tb

TRACE := $(TEST).fst

NVC := nvc

# NVC_RUN_FLAGS := $(NVC_FLAGS) --stop-time=500ns

VIEWER := surfer

VHDL_FILES := $(wildcard src/*.vhd)

VHDL_FILES += tb/testctrl_e.vhd tb/$(TB).vhd
VHDL_FILES += $(wildcard tb/*_test.vhd)

.PHONY: all clean analyze elaborate run view

all: $(TRACE)

analyze: $(VHDL_FILES)
	$(NVC) -a $(VHDL_FILES)

elaborate: analyze
	$(NVC) -e $(TEST)_test

run: elaborate
	$(NVC) -r $(TEST)_test $(NVC_RUN_FLAGS)

view: $(TRACE)
	$(VIEWER) --state-file sim/$(TB).surf.ron $(TRACE)

$(TRACE): elaborate
	$(NVC) -r $(TEST)_test  $(NVC_RUN_FLAGS) --wave=$(TRACE)

clean:
	$(RM) *.fst
	$(RM) -r ./work
