; 0 keys don't exist
; 1 keys are remapped to keypad codes
ti_keyboard_keymap:
    .db '1', '`', '\t', 'q', 'a', 0, 'z', 1 ; caps, DEL
    .db '2', '3', 'e', 'w', 's', 'x', 'c', 0 ; pgup
    .db '4', 0, 'r', 't', 'd', 'f', 'v', 0 ; n/a, pgdown
    .db '5', 0, 'u', 'y', 'h', 'g', 'b', ' ' ; n/a
    .db '6', '7', 'i', 0, 'j', 'k', 'n', 1 ; n/a, left arrow
    .db '9', '8', 'o', 0, ';', 'l', 'm', 1 ; n/a, right arrow
    .db '0', '-', 'p', '[', 0x39, 0, ',', 1 ; n/a, right arrow
    .db 0x08, '=', '\\', ']', '\n', '/', '.', 1 ; bksp, down arrow

ti_keyboard_keymap_shift:
    .db '!', '~', '\t', 'Q', 'A', 0, 'Z', 0
    .db '@', '#', 'E', 'W', 'S', 'X', 'C', 0
    .db '$', 0, 'R', 'T', 'D', 'F', 'V', 0
    .db '%', 0, 'U', 'Y', 'H', 'G', 'B', ' '
    .db '^', '&', 'I', 0, 'J', 'K', 'N', 1
    .db '(', '*', 'O', 0, ';', 'L', 'M', 1
    .db ')', '_', 'P', '{', '"', 0, '<', 1
    .db 0x08, '+', '|', '}', '\n', '?', '>', 1
