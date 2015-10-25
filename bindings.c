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

void prompt_string(SCREEN *screen, char *buffer, unsigned short buffer_length, const char *prompt_string) {
	__asm
	POP IX 
	POP IY ; screen
	POP IX ; buffer
	POP BC ; buffer_length
	POP HL ; prompt_string
		RST 0x10
		.db _CORELIB_ID
		CALL _CORELIB_PROMPTSTRING
	PUSH HL
	PUSH BC
	PUSH IY
	PUSH IX
	__endasm;
	screen; buffer; buffer_length; prompt_string;
}

void show_message(SCREEN *screen, const char *message, const char *message_list, unsigned char icon) {
	__asm
	POP IX 
	POP IY ; screen
	POP HL ; message
	POP DE ; message_list
	DEC SP
	POP BC ; icon
		RST 0x10
		.db _CORELIB_ID
		CALL _CORELIB_SHOWMESSAGE
	PUSH BC
	INC SP
	PUSH DE
	PUSH HL
	PUSH IY
	PUSH IX
	__endasm;
	screen; message; message_list; icon;
}
