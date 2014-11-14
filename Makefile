include .knightos/variables.make

INIT=/bin/fileman

ALL_TARGETS:=$(LIB)core $(ETC)magic $(ETC)extensions $(INC)corelib.inc

$(LIB)core: main.asm
	mkdir -p $(LIB)
	$(AS) $(ASFLAGS) --listing $(OUT)main.list main.asm $(LIB)core

$(ETC)magic:
	mkdir -p $(ETC)
	touch $(ETC)magic # This is an empty file for the time being

$(ETC)extensions: config/extensions
	mkdir -p $(ETC)
	cp config/extensions $(ETC)

$(INC)corelib.inc: corelib.inc
	mkdir -p $(INCLUDE)
	cp corelib.inc $(INCLUDE)

include .knightos/sdk.make
