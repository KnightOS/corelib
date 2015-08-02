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

;; drawTabs
;;  Draws a tab bar at the top of the window
;; Inputs:
;;  A: Active tab
;;  HL: Pointer to tabs descriptor
;;  IY: Screen Buffer
;; Notes:
;;  The tabs descriptor is a list of zero deliminated strings preceded by the number of tabs. Example:
;;
;;  .db 4
;;  .db "Info", 0
;;  .db "Tasks", 0
;;  .db "RAM", 0
;;  .db "Flash", 0
drawTabs:
    push af
    push bc
    push de
    push hl
        ; Draw black bar
        push hl
            ld bc, 6 << 8 | 94
            ld e, 1
            ld l, 7
            pcall(rectOR)
        pop hl
        ; B: tab counter
        ; D: X position
        ld b, (hl)
        inc hl
        ld d, 1
        neg
        add b
.loop:
        ; Current tab
        cp b
        jr nz, .allTabs
        push af
        push bc
            ; If not first tab,
            ; shift left and overlap previous tab
            ld a, d
            dec a
            or a
            jr z, _
            dec d
            ld a, d
            dec a
            push hl
                ld l, 7
                ld c, 6
                pcall(drawVLine)
            pop hl
            ; Invert tab
_:          push de
            push hl
                pcall(measureStr)
                inc a
                ld c, a
                ld b, 7
                ld l, 7
                ld e, d
                pcall(rectAND)
            pop hl
            pop de
        pop bc
        pop af
.allTabs:
        ; Shift tab after current tab left
        push af
            dec a
            cp b
            jr nz, _
            dec d
_:      pop af
        ; Draw text
        inc d
        push hl
            push de
                ld e, 8
                pcall(drawStrXOR)
                dec d
                ld e, 7
            pop hl
            ; H now contains position of start of tab
            ; Cutoff bottom of other tabs
            cp b
            jr z, _
            ld e, 12
            ld l, 12
            pcall(drawLine)
_:          ; Overlap tab after current tab
            push af
                dec a
                cp b
                jr nz, _
                push bc
                push hl
                    ld c, 6
                    ld a, h
                    ld l, 7
                    pcall(drawVLine)
                pop hl
                pop bc
_:          pop af
        pop hl
        inc d

        ; Advance HL to next tab
        push af
_:      inc hl
            ld a, (hl)
            or a
            jr nz, -_
            inc hl
        pop af
        djnz .loop
    pop hl
    pop de
    pop bc
    pop af
    ret

castleSprite:
    .db 0b10101000
    .db 0b00000000
    .db 0b10101000
    .db 0b00000000
    .db 0b10101000

castleText:
    .db "Castle", 0
promptText:
    .db "Enter:Accept MODE:Cancel", 0

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

hexSprite:
    .db 0b10100000
    .db 0b01000000
    .db 0b01000000
    .db 0b10100000

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
