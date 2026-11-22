USB_LIB_NAME := usb
USB_LIB_DIR  := $(SYNTHDIR)/$(USB_LIB_NAME)
USB_LIB      := $(USB_LIB_DIR)/$(USB_LIB_NAME)-obj$(VHDL_STANDARD).cf

LIBS += $(USB_LIB)
GHDL_FLAGS += -P$(USB_LIB_DIR)

libs: $(USB_LIB)

USB_SRC_DIR  := $(PWD)/gmm7550-usb
include $(USB_SRC_DIR)/src_files.mk

USB_LIB_VHDL_FILES := $(addprefix $(USB_SRC_DIR)/src/,$(SRC_FILES))

$(USB_LIB): $(USB_LIB_VHDL_FILES) $(CC_LIB) | $(USB_LIB_DIR)
	for f in $(USB_LIB_VHDL_FILES); do \
	  $(GHDL) analyze $(GHDL_FLAGS) --workdir=$(USB_LIB_DIR) \
	  --warn-no-default-binding --work=$(USB_LIB_NAME) $$f || exit 1; \
	done

$(USB_LIB_DIR):
	$(MKDIR) $@

.PHONY: clean_libs clean_$(USB_LIB_NAME)
clean_libs: clean_$(USB_LIB_NAME)
clean_$(USB_LIB_NAME):
	$(RM) -r $(USB_LIB_DIR)
