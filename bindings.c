#include "corelib.h"
#include <knightos/display.h>
#include <errno.h>

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
	POP IY ; screen
	POP HL ; title
	DEC SP
	POP AF ; window_flags
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

unsigned char prompt_string(SCREEN *screen, char *buffer, unsigned short buffer_length, const char *prompt_string) {
	__asm
	POP IX 
	POP IY ; screen
	POP IX ; buffer
	POP BC ; buffer_length
	POP HL ; prompt_string
		RST 0x10
		.db _CORELIB_ID
		CALL _CORELIB_PROMPTSTRING
		PUSH AF
			LD A, 0
			JR Z, PROMPT_STRING_RETURN
			INC A
PROMPT_STRING_RETURN:
			LD (HL), A
		POP AF
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

void launch_castle() {
	__asm
	RST 0x10
	.db _CORELIB_ID
	CALL _CORELIB_LAUNCHCASTLE
	__endasm;
}

void launch_threadlist() {
	__asm
	POP IX
	RST 0x10
	.db _CORELIB_ID
	CALL _CORELIB_LAUNCHTHREADLIST
	PUSH IX
	__endasm;
}

void show_error(SCREEN *screen, int errno) {
	__asm
	POP IX
	POP IY ; screen
	DEC SP
	POP AF ; errorno
	RST 0x10
	.db _CORELIB_ID
	CALL _CORELIB_SHOWERROR
	PUSH AF
	INC SP
	PUSH IY
	PUSH IX
	__endasm;
	screen;
}

void show_error_and_quit(SCREEN *screen, int errno) {
	__asm
	POP IX
	POP IY ; screen
	DEC SP
	POP AF ; errorno
	RST 0x10
	.db _CORELIB_ID
	CALL _CORELIB_SHOWERRORANDQUIT
	PUSH AF
	INC SP
	PUSH IY
	PUSH IX
	__endasm;
	screen;
}

void draw_scrollbar(SCREEN *screen, unsigned char length, unsigned char scroll) {
	__asm
	POP IX
	POP IY ; screen
	POP BC ; length, scroll
	RST 0x10
	.db _CORELIB_ID
	CALL _CORELIB_DRAWSCROLLBAR
	PUSH BC
	PUSH IY
	PUSH IX
	__endasm;
	screen; length; scroll;
}

void draw_tabs(SCREEN *screen, const char *tabs, const char *tab) {
	__asm
	POP IX
	POP IY ; screen
	POP HL ; tabs
	DEC SP
	POP AF ; tab
	RST 0x10
	.db _CORELIB_ID
	CALL _CORELIB_DRAWTABS		
	PUSH AF
	INC SP
	PUSH HL
	PUSH IY
	PUSH IX
	__endasm;
	screen; tabs; tab;
}

char show_menu(SCREEN *screen, const char *menu, unsigned char width) {
	__asm
	POP IX
	POP IY ; screen
	POP HL ; menu
	POP BC ; width
	RST 0x10
	.db _CORELIB_ID
	CALL _CORELIB_SHOWMENU		
		PUSH AF
			LD A, 0
			JR Z, SHOW_MENU_RETURN
			INC A
SHOW_MENU_RETURN:
			LD (HL), A
		POP AF			
	PUSH BC
	PUSH HL
	PUSH IY
	PUSH IX
	__endasm;
	screen; menu; width;
}

