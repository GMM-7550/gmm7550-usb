TEST ?= crc5_pipeline_comb

DUT := crc5
TB := $(DUT)_tb

TRACE := $(TEST).fst

NVC := nvc

NVC_RUN_FLAGS := $(NVC_FLAGS) --dump-arrays --stop-time=5ms

VIEWER := surfer

include src_files.mk

VHDL_FILES := $(addprefix src/,$(SRC_FILES))

VHDL_FILES += $(wildcard tb/*_e.vhd)
VHDL_FILES += $(wildcard tb/*_tb.vhd)
VHDL_FILES += $(wildcard tb/*_test.vhd)

.PHONY: all clean analyze elaborate run view crc_ref

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
	$(RM) sim/crc16

sim/crc5.txt: sim/crc5
	$< > $@

crc_ref: sim/crc5 sim/crc16

%: %.c
	$(CC) -Wall -o $@ $<
