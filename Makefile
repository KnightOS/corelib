include .knightos/variables.make

INIT=/bin/fileman

ALL_TARGETS:=$(LIB)core $(INC)corelib.inc

$(LIB)core: main.asm
	mkdir -p $(LIB)
	$(AS) $(ASFLAGS) --listing $(OUT)main.list main.asm $(LIB)core

$(INC)corelib.inc: corelib.inc
	mkdir -p $(INC)
	cp corelib.inc $(INC)

include .knightos/sdk.make
