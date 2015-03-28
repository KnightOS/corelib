include .knightos/variables.make

INIT=/bin/fileman

ALL_TARGETS:=$(LIB)core $(SLIB)core $(INC)corelib.inc $(INC)corelib.h

$(LIB)core: dependencies src/*.asm
	mkdir -p $(LIB)
	sass $(ASFLAGS) src/header.asm $(LIB)core

$(SLIB)core: dependencies $(OUT)bindings.o
	mkdir -p $(SLIB)
	scas -c -o $(SLIB)core $(OUT)bindings.o

$(INC)corelib.inc: corelib.inc
	mkdir -p $(INC)
	cp corelib.inc $(INC)

$(INC)corelib.h: corelib.h
	mkdir -p $(INC)
	cp corelib.h $(INC)

include .knightos/sdk.make
