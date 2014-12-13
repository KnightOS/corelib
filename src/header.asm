; KnightOS corelib
; General purpose application library

.nolist
libId .equ 0x02
#include "kernel.inc"
.list

.dw 0x0002

.org 0

jumpTable:
    ; Init
    ret \ nop \ nop
    ; Deinit
    ret \ nop \ nop
    jp appGetKey
    jp appWaitKey
    jp drawWindow
    jp getCharacterInput
    jp drawCharSetIndicator
    jp setCharSet
    jp getCharSet
    jp launchCastle
    jp launchThreadList
    jp showMessage
    jp showError
    jp showErrorAndQuit
    jp open
    jp drawScrollBar
    jp promptString
    jp showMenu
    .db 0xFF

#include "src/open.asm"
#include "src/graphics.asm"
#include "src/input.asm"
#include "src/promptString.asm"
#include "src/showMenu.asm"
#include "src/showMessage.asm"
#include "src/util.asm"
