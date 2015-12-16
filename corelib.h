#ifndef _CORELIB_H
#define _CORELIB_H
#include <knightos/display.h>
#include <errno.h>

#define _CORELIB_ID 0x02

#define CHARSET_UPPER 0
#define CHARSET_LOWER 1
#define CHARSET_SYMBOL 2
#define CHARSET_EXTENDED 3
#define CHARSET_HEX 4

#define WIN_DEFAULTS 0
#define WIN_SKIP_LAUNCHER 1
#define WIN_SKIP_THREADLIST 2
#define WIN_SHOW_MENU 4

#define _CORELIB_APPGETKEY 6
unsigned char app_get_key(unsigned char *lost_focus);

#define _CORELIB_APPWAITKEY 9
unsigned char app_wait_key(unsigned char *lost_focus);

#define _CORELIB_DRAWWINDOW 12
void draw_window(SCREEN *screen, const char *title, unsigned char flags);

#define _CORELIB_GETCHARACTERINPUT 15
char get_character_input(SCREEN *screen, unsigned char *raw_key);

#define _CORELIB_DRAWCHARSETINDICATOR 18
void draw_charset_indicator();

#define _CORELIB_SETCHARSET 21
void set_charset(unsigned char charset);

#define _CORELIB_GETCHARSET 24
unsigned char get_charset();

#define _CORELIB_LAUNCHCASTLE 27
void launch_castle();

#define _CORELIB_LAUNCHTHREADLIST 30
void launch_threadlist();

#define _CORELIB_SHOWMESSAGE 33
unsigned char show_message(SCREEN *screen, const char *message, const char *message_list, unsigned char icon);

#define _CORELIB_SHOWERROR 36
void show_error(SCREEN *screen, int errno);

#define _CORELIB_SHOWERRORANDQUIT 39
void show_error_and_quit(SCREEN *screen, int errno);

#define _CORELIB_OPEN 42
unsigned char open_file(const char *path);

#define _CORELIB_DRAWSCROLLBAR 45
void draw_scrollbar(SCREEN *screen, unsigned char length, unsigned char scroll);

#define _CORELIB_PROMPTSTRING 48
unsigned char prompt_string(SCREEN *screen, char *buffer, unsigned short buffer_length, const char *prompt_string);

#define _CORELIB_SHOWMENU 51
char show_menu(SCREEN *screen, const char *menu, unsigned char width);

#define _CORELIB_WORDWRAP 54
void draw_string_word_wrap(SCREEN *screen, const char *text, unsigned char x, unsigned char y, unsigned char x_max, unsigned char y_max);

#define _CORELIB_DRAWTABS 57
void draw_tabs(SCREEN *screen, const char *tabs, const char *tab);


#endif
