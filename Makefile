DUT := ddff
TB := $(DUT)_tb

TRACE := $(TB).fst

NVC := nvc

NVC_RUN_FLAGS := $(NVC_FLAGS) --stop-time=500ns

VIEWER := surfer

VHDL_FILES := $(wildcard src/*.vhd)
VHDL_FILES += $(wildcard tb/*.vhd)

.PHONY: all clean analyze elaborate run view

all: $(TRACE)

analyze: $(VHDL_FILES)
	$(NVC) -a $(VHDL_FILES)

elaborate: analyze
	$(NVC) -e $(TB)

run: elaborate
	$(NVC) -r $(TB) $(NVC_RUN_FLAGS)

view: $(TRACE)
	$(VIEWER) $(TRACE)

$(TRACE): elaborate
	$(NVC) -r $(TB)  $(NVC_RUN_FLAGS) --wave=$(TRACE)

clean:
	$(RM) $(TRACE)
