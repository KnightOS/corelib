#include "corelib.h"
#include <knightos/display.h>

unsigned char app_get_key(unsigned char *lost_focus) __naked {
	__asm
	POP IX
	POP HL
		RST 0x10
		.db _CORELIB_ID
		CALL _CORELIB_APPGETKEY
		PUSH AF
			LD A, 0
			JR Z, APP_GET_KEY_KEPT_FOCUS
			INC A
APP_GET_KEY_KEPT_FOCUS:
			LD (HL), A
		POP AF
	PUSH HL
	PUSH IX
	LD L, A
	RET
	__endasm;
	lost_focus;
}

unsigned char app_wait_key(unsigned char *lost_focus) __naked {
	__asm
	POP IX
	POP HL
		RST 0x10
		.db _CORELIB_ID
		CALL _CORELIB_APPWAITKEY
		PUSH AF
			LD A, 0
			JR Z, APP_WAIT_KEY_KEPT_FOCUS
			INC A
APP_WAIT_KEY_KEPT_FOCUS:
			LD (HL), A
		POP AF
	PUSH HL
	PUSH IX
	LD L, A
	RET
	__endasm;
	lost_focus;
}
 
void draw_window(SCREEN *screen, const char *title, unsigned char window_flags) {
	__asm
	POP IX
	POP IY
	POP HL
	DEC SP
	POP AF
		RST 0x10
		.db _CORELIB_ID
		CALL _CORELIB_DRAWWINDOW
	PUSH AF
	INC SP
	PUSH HL
	PUSH IY
	PUSH IX
	__endasm;
	screen; title; window_flags;
}
