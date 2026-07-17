TEST ?= crc5_seq

DUT := crc5
TB := $(DUT)_tb

TRACE := $(TEST).fst

NVC := nvc

# NVC_RUN_FLAGS := $(NVC_FLAGS) --stop-time=500ns

VIEWER := surfer

VHDL_FILES := $(wildcard src/*.vhd)

VHDL_FILES += $(wildcard tb/*_e.vhd)
VHDL_FILES += $(wildcard tb/*_tb.vhd)
VHDL_FILES += $(wildcard tb/*_test.vhd)

.PHONY: all clean analyze elaborate run view

all: $(TRACE)

analyze: $(VHDL_FILES)
	for f in $(VHDL_FILES); do \
	$(NVC) -a $$f; \
	done

elaborate: analyze
	$(NVC) -e $(TEST)_test

run: elaborate sim/crc5.txt
	$(NVC) -r $(TEST)_test $(NVC_RUN_FLAGS)

view: $(TRACE)
	$(VIEWER) --state-file sim/$(TB).surf.ron $(TRACE)

$(TRACE): elaborate sim/crc5.txt
	$(NVC) -r $(TEST)_test  $(NVC_RUN_FLAGS) --wave=$(TRACE)

clean:
	$(RM) *.fst
	$(RM) -r ./work
	$(RM) sim/crc5 sim/crc5.txt

sim/crc5.txt: sim/crc5
	$< > $@

%: %.c
	$(CC) -Wall -o $@ $<
