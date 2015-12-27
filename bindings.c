#include "corelib.h"
#include <knightos/display.h>
#include <errno.h>
#include <stdbool.h>

unsigned char app_get_key(unsigned char *lost_focus) __naked {
	__asm
	POP DE
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
	PUSH DE
	LD L, A
	RET
	__endasm;
	lost_focus;
}

unsigned char app_wait_key(unsigned char *lost_focus) __naked {
	__asm
	POP DE
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
	PUSH DE
	LD L, A
	RET
	__endasm;
	lost_focus;
}
 
void draw_window(SCREEN *screen, const char *title, unsigned char window_flags) {
	__asm
	POP DE
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
	PUSH DE
	__endasm;
	screen; title; window_flags;
}

bool prompt_string(SCREEN *screen, unsigned short buffer_length, const char *prompt_string, char *buffer) {
	__asm
	POP DE ; return address
	POP IY ; screen
	POP BC ; length
	POP HL ; prompt_string
	POP IX ; buffer
		RST 0x10
		.db _CORELIB_ID
		CALL _CORELIB_PROMPTSTRING
		LD (HL), IX ; input
		LD L, A ; boolean
	PUSH IX
	PUSH HL
	PUSH BC
	PUSH IY
	PUSH DE
	__endasm;
	screen; buffer_length; prompt_string; buffer;
}

unsigned char show_message(SCREEN *screen, const char *message, const char *message_list, unsigned char icon) {
	__asm
	POP AF
	POP IY ; screen
	POP HL ; message
	POP DE ; message_list
	POP BC ; icon
	PUSH BC
	PUSH DE
	PUSH HL
	PUSH IY
	PUSH AF
	LD B, C
		RST 0x10
		.db _CORELIB_ID
		CALL _CORELIB_SHOWMESSAGE
	LD L, A
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
	POP DE
	RST 0x10
	.db _CORELIB_ID
	CALL _CORELIB_LAUNCHTHREADLIST
	PUSH DE
	__endasm;
}

void show_error(SCREEN *screen, int errno) {
	__asm
	POP DE
	POP IY ; screen
	DEC SP
	POP AF ; errorno
	RST 0x10
	.db _CORELIB_ID
	CALL _CORELIB_SHOWERROR
	PUSH AF
	INC SP
	PUSH IY
	PUSH DE
	__endasm;
	screen;
}

void show_error_and_quit(SCREEN *screen, int errno) {
	__asm
	POP DE
	POP IY ; screen
	DEC SP
	POP AF ; errorno
	RST 0x10
	.db _CORELIB_ID
	CALL _CORELIB_SHOWERRORANDQUIT
	PUSH AF
	INC SP
	PUSH IY
	PUSH DE
	__endasm;
	screen;
}

void draw_scrollbar(SCREEN *screen, unsigned char length, unsigned char scroll) {
	__asm
	POP DE
	POP IY ; screen
	POP BC ; length, scroll
	RST 0x10
	.db _CORELIB_ID
	CALL _CORELIB_DRAWSCROLLBAR
	PUSH BC
	PUSH IY
	PUSH DE
	__endasm;
	screen; length; scroll;
}

void draw_tabs(SCREEN *screen, const char *tabs, const char *tab) {
	__asm
	POP DE
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
	PUSH DE
	__endasm;
	screen; tabs; tab;
}

char show_menu(SCREEN *screen, const char *menu, unsigned char width) {
	__asm
	POP DE
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
	PUSH DE
	__endasm;
	screen; menu; width;
}

bool open_file(const char *path) {
	__asm
	POP HL ; Return point
	POP DE ; path
	RST 0x10
	.db _CORELIB_ID
	CALL _CORELIB_OPEN
	PUSH DE ; restore path
	LD L, 0
	JR Z, .error
	INC L
.error:
	JP (HL)
	__endasm;
	path; 
}
/** TODO: ANSI? **/
char get_character_input(unsigned char *raw_key) __naked {
	__asm
	POP DE
	POP HL
		RST 0x10
		.db _CORELIB_ID
		CALL _CORELIB_GETCHARACTERINPUT
		PUSH AF
		PUSH BC
			LD (HL), B ; raw keypress
		POP BC
		POP AF
	PUSH HL
	PUSH DE
	LD L, A ; ansii character
	RET
	__endasm;
	raw_key;
}


void draw_charset_indicator() {
	__asm
	POP DE ; return address
		RST 0x10
		.db _CORELIB_ID
		CALL _CORELIB_DRAWCHARSETINDICATOR	
	PUSH DE
	__endasm;
}

void set_charset(unsigned char charset) {
	__asm
	POP DE ; return address
	DEC SP
	POP AF ; charset
		RST 0x10
		.db _CORELIB_ID
		CALL _CORELIB_SETCHARSET	
	PUSH AF
	INC SP
	PUSH DE
	__endasm;
	charset;

}

unsigned char get_charset() {
	__asm
	POP DE ; return address
	DEC SP
		RST 0x10
		.db _CORELIB_ID
		CALL _CORELIB_GETCHARSET	
		LD L, A
	INC SP
	PUSH DE
	__endasm;

}