#ifndef _CORELIB_H
#define _CORELIB_H
#include <knightos/display.h>
#include <errno.h>
#include <stdbool.h>

#define _CORELIB_ID 0x02

#define CHARSET_UPPER 0
#define CHARSET_LOWER 1
#define CHARSET_SYMBOL 2
#define CHARSET_EXTENDED 3
#define CHARSET_HEX 4

/** Presets for draw_window **/
#define WIN_DEFAULTS 0
#define WIN_SKIP_LAUNCHER 1
#define WIN_SKIP_THREADLIST 2
#define WIN_SHOW_MENU 4


/**
* Similar to the kernels getKey but listens for hotkeys
**/
#define _CORELIB_APPGETKEY 6
unsigned char app_get_key(unsigned char *lost_focus);

/**
* Similar to the kernels waitKey but listens for hotkeys
**/
#define _CORELIB_APPWAITKEY 9
unsigned char app_wait_key(unsigned char *lost_focus);

/**
* Draws the corelib window.
* Note: flags is a bit
* 0x0: Set to skip castle graphic
* 0x1: Set to skip thread list graphic
* 0x2: Set to draw menu graphic (note the opposite use from others)
* You can use WIN_DEFAULTS, WIN_SKIP_LAUNCHER, WIN_SKIP_THREADLIST, and WIN_SHOW_MENU, all of which are defined at the top of this file.
**/
#define _CORELIB_DRAWWINDOW 12
void draw_window(SCREEN *screen, const char *title, unsigned char flags);

/**
* Gets a key input from the user. The function returns the ANSI key, while &raw_key is loaded with the raw keycode
* Note: handles draw_charset_indicator() for you
**/
#define _CORELIB_GETCHARACTERINPUT 15
char get_character_input(unsigned char *raw_key);

/**
* Draws the charset indicator in the top right
**/
#define _CORELIB_DRAWCHARSETINDICATOR 18
void draw_charset_indicator();

/**
* Sets the charset
* Note: You can use CHARSET_UPPER, CHARSET_LOWER, CHARSET_SYMBOL, CHARSET_EXTENDED, and CHARSET_HEX
* all of which are defined at the top of this file.
**/
#define _CORELIB_SETCHARSET 21
void set_charset(unsigned char charset);

/**
* Returns the current charset
**/
#define _CORELIB_GETCHARSET 24
unsigned char get_charset();

/**
* Launches the launcher
**/
#define _CORELIB_LAUNCHCASTLE 27
void launch_castle();

/**
* Launches the threadlist
**/
#define _CORELIB_LAUNCHTHREADLIST 30
void launch_threadlist();

/**
* Shows a message prompt. 
* message is the message shown
* message_list is a string as such: "\x02Option 1\x00Option 2\x00"
**/
#define _CORELIB_SHOWMESSAGE 33
unsigned char show_message(SCREEN *screen, const char *message, const char *message_list, unsigned char icon);

/**
* Displays an error. A list of kernel errors can be found in errno.h
**/
#define _CORELIB_SHOWERROR 36
void show_error(SCREEN *screen, int errno);

/**
* Displays an error and quits. A list of kernel errors can be found in errno.h
**/
#define _CORELIB_SHOWERRORANDQUIT 39
void show_error_and_quit(SCREEN *screen, int errno);

/**
* Launches a file
* More information: https://github.com/KnightOS/KnightOS/issues/143
**/
#define _CORELIB_OPEN 42
bool open_file(const char *path);

/**
* Draws a scrollbar. 
**/
#define _CORELIB_DRAWSCROLLBAR 45
void draw_scrollbar(SCREEN *screen, unsigned char length, unsigned char scroll);

/**
* Opens a prompt. Returns 0 (false) if canceled and 1 (true) if accepted.
* &buffer is loaded with the result if accepted
* prompt_string is the title of the dialog
**/
#define _CORELIB_PROMPTSTRING 48
bool prompt_string(SCREEN *screen, unsigned short buffer_length, const char *prompt_string, char *buffer);

/**
* Initializes an F3 menu.
* menu is a string such as "\x03Info\x00Tasks\x00RAM\x00"
* Note: draw_windows flag should be '0x02' so it draws the menu graphic on the bottom bar
**/
#define _CORELIB_SHOWMENU 51
char show_menu(SCREEN *screen, const char *menu, unsigned char width);

/**
* Draws a string but wraps at words
**/
#define _CORELIB_WORDWRAP 54
void draw_string_word_wrap(SCREEN *screen, const char *text, unsigned char x, unsigned char y, unsigned char x_max, unsigned char y_max);

/**
* Draws a set of tabs.
* Tabs is a string such as "\x04Info\x00 Tasks\x00 RAM\x00 Flash\x00"
* Tab is the current tab
**/
#define _CORELIB_DRAWTABS 57
void draw_tabs(SCREEN *screen, const char *tabs, const char *tab);


#endif
