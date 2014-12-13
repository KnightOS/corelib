include .knightos/variables.make

INIT=/bin/fileman

ALL_TARGETS:=$(LIB)core $(INC)corelib.inc

$(LIB)core: src/*.asm
	mkdir -p $(LIB)
	$(AS) $(ASFLAGS) --listing $(OUT)header.list src/header.asm $(LIB)core

$(INC)corelib.inc: corelib.inc
	mkdir -p $(INC)
	cp corelib.inc $(INC)

include .knightos/sdk.make
