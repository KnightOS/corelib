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

; Same as kernel getKey, but listens for
; F1 and F5 and acts accordingly
; Z is reset if the thread lost focus during this call
appGetKey:
    pcall(getKey)
    jr checkKey

appWaitKey:
    pcall(waitKey)
    ;jr checkKey

checkKey:
    cp kYEqu
    ijp(z, launchCastle)
    cp kGraph
    ijp(z, launchThreadList)
    cp a
    ret

launchCastle:
    pcall(fullScreenWindow)
    push de
        ild(de, castlePath)
        di
        pcall(launchProgram)
    pop de
    pcall(suspendCurrentThread)
    pcall(flushKeys)
    or 1
    ret

launchThreadList:
    pcall(fullScreenWindow)
    push de
        ild(de, threadListPath)
        di
        pcall(launchProgram)
    pop de
    pcall(suspendCurrentThread)
    pcall(flushKeys)
    or 1
    ret

;; drawWindow [corelib]
;;  Draws a window layout on the screen buffer.
;; Inputs:
;;  IY: Screen buffer
;;  HL: Window title text
;;  A: Flags:
;;     Bit 0: Set to skip castle graphic
;;     Bit 1: Set to skip thread list graphic
;;     Bit 2: Set to draw menu graphic (note the opposite use from others)
;; Notes:
;;  Clears the buffer, then draws the standard frame and other items on it
drawWindow:
    push de
    push bc
    push hl
    push af
        pcall(clearBuffer)
        ; "window"
        push iy \ pop hl
        ld (hl), 0xff
        ld e, l
        ld d, h
        inc de
        ld bc, 57 * 12 - 1
        ldir
        
        ld e, 1
        ld l, 7
        ld c, 94
        ld b, 49
        pcall(rectXOR)
        
        res 7, (iy + 0)
        res 0, (iy + 11)
        
        bit 0, a
        jr nz, _
            ild(hl, castleSprite)
            ld b, 5
            ld de, 256 + 58
            pcall(putSpriteOR)
_:      pop af \ push af
        bit 1, a
        jr nz, _
            ild(hl, threadListSprite)
            ld d, 89
            ld b, 6
            pcall(putSpriteOR)
_:      pop af \ push af
        bit 2, a
        jr z, _
            ild(hl, menuText)
            ld d, 40
            pcall(drawStr)

            ild(hl, menuSprite)
            ld d, 56
            inc e
            ld b, 3
            pcall(PutSpriteOR)
_:      pop af \ pop hl \ push hl \ push af
        ld de, 0x0201
        pcall(drawStrXOR)
    pop af
    pop hl
    pop bc
    pop de
    ret

;; drawScrollBar
;; Inputs:
;;  B: Length of bar in pixels
;;  C: Position of top of bar (0-49)
;;  IY: Screen Buffer
drawScrollBar:
    push af
    push hl
        push bc
            ; Draw left side
            ld a, 94
            ld l, 7
            ld c, 49
            pcall(drawVLine)
            ; Clear right side
            inc a
            pcall(drawVLineAND)
        ; Draw bar
        pop bc
        ; Set Y
        ld a, 7
        add c
        ld l, a
        ; Set X
        ld a, 95
        ; Set length
        ld c, b
        pcall(drawVLine)
    pop hl
    pop af
    ret

drawOverlay:
    ld e, 0
    ld l, 16
    ld bc, (49 - 15) * 256 + 96
    pcall(rectOR)

    ld e, 0
    ld l, 17
    ld bc, (48 - 16) * 256 + 96
    pcall(rectXOR)
    ret

;; promptString [corelib]
;;  Prompts the user to input a string, and returns that string.
;; Inputs:
;;  IX: Memory to hold string
;;  IY: Display buffer to draw on
;;  HL: Prompt text
;;  BC: Maximum length
;; Outputs:
;;  A: 0 = Cancelled, 1 = Accepted
;; Notes:
;;  The memory passed via IX should be initialized with the starting value of the string.
;;  If you want the user to enter a string without a default value, set (IX) to zero.
;;  
;;  You must re-draw your UI after calling this.
promptString:
    push ix
    push de
    push bc
    push hl
        icall(drawOverlay)
        ; Draw text
    pop hl \ push hl
        ld de, 0x0112
        pcall(drawStr)
        ild(hl, promptText)
        ld de, 0x012B
        pcall(drawStr)
        ; Draw input area
        push bc
            ld e, 1
            ld l, 24
            ld bc, 9 * 256 + 94
            pcall(rectOR)

            ld e, 2
            ld l, 25
            ld bc, 7 * 256 + 92
            pcall(rectXOR)
        pop bc
        ; Initialize variables
        xor a
        ild((.caret_state), a)
        icall(setCharSet)
        ld a, 3
        ild((.caret_x), a)
        ild((.max_length), bc)
        ild((.start_address), ix)
        push ix \ pop hl
        pcall(strlen)
        ild((.current_length), bc)
        pcall(flushKeys)
.input_loop:
        icall(.draw_caret)
        pcall(fastCopy)
        icall(getCharacterInput)
        cp '\n'
        jr z, .accept
        or a
        jr nz, .insert_character
        ld a, b
        cp kMODE
        jr z, .cancel
        jr .input_loop
.insert_character:
        icall(.erase_caret)
        ; Handle character
        ; TODO: Checks on length
        ; TODO: Scrolling
        ; TODO: Backspace
        ; TODO: Seeking
        ld (ix), a
        inc ix
        ld (ix), 0
        ld e, 26
        ild(hl, .caret_x)
        ld d, (hl)
        pcall(drawChar)
        ld (hl), d
        pcall(flushKeys)
        jr .input_loop
.accept:
    pcall(flushKeys)
    pop hl
    pop bc
    pop de
    pop ix
    ld a, 1
    ret
.cancel:
    pcall(flushKeys)
    pop hl
    pop bc
    pop de
    pop ix
    xor a
    ret
.draw_caret:
    ild(hl, .caret_state)
    inc (hl)
    ild(de, (.caret_x - 1))
    ld e, 26
    ld b, 5
    bit 7, (hl)
    ild(hl, textCaret)
    pcall(z, putSpriteOR)
    pcall(nz, putSpriteAND)
    ret
.erase_caret:
    push af
        ild(hl, .caret_state)
        xor a
        ld (hl), a
        ild(de, (.caret_x - 1))
        ld e, 26
        ld b, 5
        ild(hl, textCaret)
        pcall(putSpriteAND)
    pop af
    ret
.caret_state:
    .db 0
.caret_x:
    .db 3
.max_length:
    .dw 0
.current_length:
    .dw 0
.start_address:
    .dw 0

;; showMenu [corelib]
;;  Shows a user-specified menu of options.
;; Inputs:
;;  HL: Pointer to menu descriptor
;;  C: Width of menu (in pixels)
;; Outputs:
;;  A: Index of selected item, or 0xFF if cancelled
;; Notes:
;;  The menu descriptor may contain up to 5 different options, preceeded by the number of
;;  options. Example:
;;  
;;  .db 3
;;  .db "Thing 1", 0
;;  .db "Thing 2", 0
;;  .db "Thing 3", 0
;;  
;;  You must re-draw your UI after calling this. Note that the width of your menu does not
;;  include the border.
showMenu:
    push af
    push de
    push bc
    push hl
        push bc
            srl c ; c /= 2
            ld a, c \ neg
            add a, 96 / 2
            ld e, a ; E = X
        pop bc
        inc c \ inc c ; C = Width
        ld a, (hl)
        ; A *= 6
        ld b, a
        add a, a \ add a, a ; * 4
        add a, b \ add a, b ; * 6
        ld b, a ; Height
        inc b \ inc b ; Add space 

        ld l, 64 - (8 + 2)
        neg
        add a, l
        ld l, a ; L = Y

        push bc \ push de \ push hl
            pcall(rectOR)
        pop hl \ pop de \ pop bc
        inc e \ inc l ; X, Y
        dec c \ dec c ; Width, Height
        push de \ push hl
            pcall(rectAND)
        pop hl \ pop de
        ld d, e
        ld e, l
    pop hl \ push hl
        ld a, d
        add a, 6
        ld d, a
        ld b, (hl)
        inc e
        push de
.names_loop:
            inc hl
            pcall(drawStr)
            push bc
                pcall(strlen)
                add hl, bc
                ld b, a
                pcall(newline)
            pop bc
            djnz .names_loop

            ild(hl, caret)
            ld de, 0x383B
            ld b, 3
            pcall(putSpriteAND)
            ild(hl, caret_inverted)
            pcall(putSpriteOR)
        pop de
        dec d \ dec d \ dec d \ dec d

        ld c, 0 ; Selection index
        icall(.drawIndicator)

.input_loop:
        pcall(fastCopy)
        pcall(flushKeys)
        pcall(waitKey)
        cp kMODE
        jr z, .cancel
        cp kF3
        jr z, .cancel
        cp kDown
        jr z, .down
        cp kUp
        jr z, .up
        cp kEnter
        jr z, .confirm
        cp k2nd
        jr z, .confirm
        jr .input_loop
.down:
    pop hl \ push hl
        ld a, (hl)
        dec a
        cp c
        jr z, .input_loop
        icall(.drawIndicator)
        inc c
        icall(.drawIndicator)
        jr .input_loop
.up:
        xor a
        cp c
        jr z, .input_loop
        icall(.drawIndicator)
        dec c
        icall(.drawIndicator)
        jr .input_loop
.confirm:
        ld a, c
    pop hl
    pop bc
    pop de
    inc sp \ inc sp ; pop af
    ret
.cancel:
    pop hl
    pop bc
    pop de
    pop af
    ld a, 0xFF
    ret
.drawIndicator:
        ld a, c
        add a, a \ add a, a \ add a, c \ add a, c ; A *= 6
        add a, e
        push de
            ld e, a
            ild(hl, selectionIndicatorSprite)
            ld b, 5
            pcall(putSpriteXOR)
        pop de
        ret

;; showMessage [corelib]
;;  Displays a message box on the screen buffer.
;; Inputs:
;;  HL: Message text
;;  DE: Option list
;;  A: Default option, zero based
;;  B: Icon index (0: Exclamation mark)
;;  IY: Screen buffer
;; Outputs:
;;  A: Selected option index
;; Notes:
;;  Option list may be up to two different options, preceded by the number of options. Example:
;;  
;;      .db 2, "Yes", 0, "No", 0
;;  
;;  Or:
;;  
;;      .db 1, "Dismiss", 0
;;  
;;  You must re-draw your UI after calling this.
showMessage:
    push af
        push de
            push hl
                push bc
                    icall(drawOverlay)

                    ; Draw our nice icon. Note, in the future it might be nice to have a table of
                    ; different icons and then do something like
                    ; ld hl, iconTable \ ld e, b \ ld d, 0 \ add hl, de
                    ; to get a pointer to the table (with a check to ensure the icon index is valid.)
                pop bc \ push bc
                    ld a, b
                    or a ; cp 0
                    jr nz, .skipIcon

                    ld b, 8
                    ld de, 10 * 256 + 18
                    ild(hl, exclamationSprite1)
                    pcall(putSpriteOR)
                    ld e, 26
                    ild(hl, exclamationSprite2)
                    pcall(putSpriteOR)
.skipIcon:
        pop bc \ pop hl \ pop de \ pop af \ push hl \ push bc \ push af \ push de
                    ; For now we'll hardcode the location of the text, but if wider icons get
                    ; implemented the text's X coordinate needs to be calculated (or pre-stored).
                    ld de, 16 * 256 + 18 ; d = 26, e = 18 (coords)
                    ld bc, (96 - 16) * 256 + 37 ; margins
                    ld a, d ; margin
                    pcall(wrapStr)

                    ; Draw all the options
                    ld de, 16 * 256 + 37
                    ld b, d ; left margin
                pop hl \ pop af \ push hl \ push af ; need the address of options, originally in de
                ld c, (hl)
                dec c ; We need our number of options to be zero-based
                inc hl ; Go to start of first string
                pcall(drawStr)
                ld a, c
                or a
                jr z, _ ; Skip drawing second option if there isn't one
                xor a
                push bc \ ld bc, -1 \ cpir \ pop bc ; Seek to end of string
                ld a, '\n' \ pcall(drawChar)
                pcall(drawStr)

_:          pop af \ push af ; default option
                cp c
                jr c, _
                jr z, _
                xor a ; default option is too large
_:              ld b, 5 ; height of sprite
.answerloop:
                    push af
                        or a \ rlca \ ld d, a \ rlca \ add d ; A *= 6
                        ld d, 12
                        add a, 37 \ ld e, a
                    pop af
                    ; Draw!
                    ild(hl, selectionIndicatorSprite)
                    pcall(putSpriteOR)

                    pcall(fastCopy)
                    push af
_:                      pcall(flushKeys)
                        pcall(waitKey)
                        cp kEnter
                        jr z, .answerloop_Select
                        cp k2nd
                        jr z, .answerloop_Select
                        cp kDown
                        jr z, .answerloop_Down
                        cp kUp
                        jr nz, -_ ; fall thru to .answerloop_Up
.answerloop_Up:
                    pop af
                    pcall(putSpriteXOR)
                    or a
                    jr z, .answerloop
                    dec a
                    jr .answerloop
.answerloop_Down:
                    pop af
                    pcall(putSpriteXOR)
                    cp c
                    jr z, .answerloop
                    inc a
                    jr .answerloop
.answerloop_Select:
                    pop af
                inc sp \ inc sp
            pop de
        pop bc
    pop hl
    ret

;; getCharacterInput [corelib]
;;  Gets a key input from the user.
;; Outputs:
;;  A: ANSI character
;;  B: Raw keypress
;; Notes:
;;  Uses the upper-right hand corner of the screen to display
;;  input information, assumes you have a window chrome prepared.
;;  Possible values include \n and backspace (0x08).
;;  Also watches for F1/F5 to launch castle/thread list
getCharacterInput:
    icall(drawCharSetIndicator)

    ld b, 0
    icall(appGetKey)
    jr nz, .lostFocus
    or a
    ret z ; Return if zero

    ld b, a

    ; Check for special keys
    cp kAlpha
    jr z, setCharSetFromKey
    cp k2nd
    jr z, setCharSetFromKey

    push bc

    ; Get key value
    sub 9
    jr c, _
    cp 41
    jr nc, _

    push hl
        push af
            ild(a, (charSet))
            add a, a \ add a, a \ add a, a \ ld b, a \ add a, a \ add a, a \ add a, b ; A * 40
            ild(hl, characterMapLowercase)
            add a, l
            ld l, a
            jr nc, $+3 \ inc h
        pop af

        add a, l
        ld l, a
        jr nc, $+3 \ inc h
        ld a, (hl)
    pop hl
    pop bc
    ret

_:  xor a
    pop bc
    cp a
    ret
.lostFocus:
    or 1
    ld a, 0
    ret

setCharSetFromKey:
    cp kAlpha
    icall(z, setAlphaKey)
    cp k2nd
    icall(z, set2ndKey)
    pcall(flushKeys)
    xor a
    ret

setAlphaKey: ; Switch between alpha charsets
    ild(a, (charSet))
    inc a
    cp 2 ; Clamp to <2
    jr c, _
        xor a
_:  ild((charSet), a)
    ret

set2ndKey: ; Switch between symbol charsets
    ild(a, (charSet))
    inc a
    cp 4 ; Clamp 1 < A < 4
    jr c, _
        ld a, 2
_:  cp 2
    jr nc, _
        ld a, 2
_:  ild((charSet), a)
    ret

; Draws the current character set indicator on a window
drawCharSetIndicator:
    push hl
    push de
    push bc
    push af
        ; Clear old sprite, if present
        ild(hl, clearCharSetSprite)
        ld de, 0x5C02
        ld b, 4
        pcall(putSpriteOR)

        ild(a, (charSet))
        ; Get sprite in HL
        add a, a \ add a, a ; A * 4
        ild(hl, charSetSprites)
        add a, l
        ld l, a
        jr nc, $+3 \ inc h
        ; Draw sprite
        pcall(putSpriteXOR)
    pop af
    pop bc
    pop de
    pop hl
    ret

charSet:
    .db 0

; Sets the character mapping to A.
; 0: uppercase \ 1: lowercase \ 2: symbols \ 3: extended
setCharSet:
    cp 4
    ret nc ; Only allow 0-3
    ild((charSet), a)
    ret

getCharSet:
    ild(a, (charSet))
    ret

;; showError [corelib]
;;  Displays a user-friendly error message if appliciable.
;; Inputs:
;;  A: Error code
showError:
    ret z
    push af
        or a
        jr z, showError_exitEarly
        ; Show error
        push de
        push bc
        push hl
            dec a
            ild(hl, errorMessages)
            add a \ add l \ ld l, a \ jr nc, $+3 \ inc h
            ld e, (hl) \ inc hl \ ld d, (hl)
            push de
            push ix
                push hl \ pop ix
                pcall(memSeekToStart)
                push ix \ pop bc
            pop ix
            pop hl
            add hl, bc

            ild(de, dismissOption)
            xor a
            ld b, a
            icall(showMessage)
        pop hl
        pop bc
        pop de
showError_exitEarly:
    pop af
    ret

;; showErrorAndQuit [corelib]
;;  Displays a user-friendly error message, if applicable,
;;  then quits the current thread.  This function does not
;;  return if NZ and if A != 0.
;; Inputs:
;;  A: Error code
showErrorAndQuit:
    ret z
    push af
        or a
        jr z, showError_exitEarly
        icall(showError)
        jp exitThread

;; open [corelib]
;;  Opens a file with the associated application.
;; Inputs:
;;  DE: Path to file
;; Outputs:
;;  A: New thread ID
;;  Z: Set on success, reset on failure
;; Notes:
;;  This checks to see if it's a KEXC, then looks in /etc/magic,
;;  then /etc/extensions, and then if it looks like a text file, it
;;  opens it with /etc/editor. If all of that fails, it returns NZ.
open:
    ld a, i
    push af
        di
        ; Check for KEXC
        push de
            pcall(openFileRead)
            ijp(nz, .isKEXCfail)

            ld bc, 5
            pcall(malloc)
            ijp(nz, .isKEXCfail)

            dec bc
            pcall(streamReadBuffer)
            ijp(nz, .isKEXCfail)
            pcall(closeStream)

            ld (ix + 4), 0
            push ix \ pop hl
            ild(de, kexcString)
            pcall(strcmp)
            pcall(free)
        pop de

        ; If the file is a KEXC, directly launch it
        jr nz, .notKEXC
        pcall(launchProgram)
        ld (kernelGarbage), a
        jr nz, .fail
        ild(hl, open_returnPoint)
        pcall(setReturnPoint)
        jr .end

.notKEXC:
        ; Else, open it with the text editor
        ex de, hl

        ; Copy HL into some new memory really quick
        pcall(strlen)
        inc bc
        pcall(malloc)
        jr nz, .fail
        push ix \ pop de
        push de
            ldir
        pop hl

        ; Launch the text editor
        ild(de, editorPath)
        pcall(launchProgram)
        ld (kernelGarbage), a
        jr nz, .fail

        ; Tell the editor the path of the text file
        push hl \ pop ix
        pcall(reassignMemory)
        pcall(setInitialDE)
        ld h, 1 ; "open file"
        pcall(setInitialA)
        ild(hl, open_returnPoint)
        pcall(setReturnPoint)

        jr .end

.notKEXCfail:
        pop ix
        jr .fail
.isKEXCfail:
        pop de
        ;jr .fail
.fail:
    pop af
    ld a, (kernelGarbage)
    ijp(po, _)
    ei
_:  or 1
    ret

.end:
    pop af
    ld a, (kernelGarbage)
    ijp(po, _)
    ei
_:  cp a
    ret

open_returnPoint:
    ild(de, castlePath)
    pcall(launchProgram)
    pcall(killCurrentThread)

#include "errors.asm"
#include "characters.asm"

castlePath:
    .db "/bin/launcher", 0
threadlistPath:
    .db "/bin/switcher", 0
magicPath:
    .db "/etc/magic", 0
extensionsPath:
    .db "/etc/extensions", 0
editorPath:
    .db "/bin/editor", 0

kexcString:
    .db "KEXC", 0

castleSprite:
    .db 0b10101000
    .db 0b00000000
    .db 0b10101000
    .db 0b00000000
    .db 0b10101000

castleText:
    .db "Castle", 0
promptText:
    .db "Enter: Accept       MODE: Cancel", 0

threadListSprite:
    .db 0b10111100
    .db 0b00000000
    .db 0b10111100
    .db 0b00000000
    .db 0b10111100
    .db 0b00000000

textCaret:
    .db 0b10000000
    .db 0b10000000
    .db 0b10000000
    .db 0b10000000
    .db 0b10000000
    .db 0b10000000

menuSprite:
caret:
    .db 0b00100000
    .db 0b01110000
    .db 0b11111000

caret_inverted:
    .db 0b11111000
    .db 0b01110000
    .db 0b00100000

menuText:
    .db "Menu", 0

clearCharSetSprite:
    .db 0b11100000
    .db 0b11100000
    .db 0b11100000
    .db 0b11100000
charSetSprites:

lowercaseASprite:
    .db 0b00000000
    .db 0b01100000
    .db 0b10100000
    .db 0b01100000

uppercaseASprite:
    .db 0b01000000
    .db 0b10100000
    .db 0b11100000
    .db 0b10100000

symbolSprite:
    .db 0b01000000
    .db 0b11000000
    .db 0b01000000
    .db 0b11100000

extendedSprite:
    .db 0b01000000
    .db 0b01000000
    .db 0b00000000
    .db 0b01000000

exclamationSprite1:
    .db 0b01110000
    .db 0b10001000
    .db 0b10001000
    .db 0b10001000
    .db 0b10001000
    .db 0b10001000
    .db 0b10001000
    .db 0b10001000

exclamationSprite2:
    .db 0b10001000
    .db 0b01110000
    .db 0b00000000
    .db 0b01110000
    .db 0b10001000
    .db 0b10001000
    .db 0b10001000
    .db 0b01110000

selectionIndicatorSprite:
    .db 0b10000000
    .db 0b11000000
    .db 0b11100000
    .db 0b11000000
    .db 0b10000000
