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
        ; Initialize variables
        xor a
        ild((.caret_state), a)
        ild((.max_length), bc)
        ild((.start_address), ix)
        push ix \ pop hl
        pcall(strlen)
        ild((.current_length), bc)
        add ix, bc
        pcall(measureStr)
        add a, 3
        ild((.caret_x), a)

        icall(.draw_input_area)
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
        pcall(flushKeys)
        ; Handle character
        icall(.erase_caret)
        ; TODO: Checks on length
        ; TODO: Scrolling
        ; TODO: Seeking
        cp '\b'
        jr z, .handle_bksp

        ld (ix), a
        inc ix
        ld (ix), 0
        icall(.draw_input_area)

        ; Advance caret
        pcall(measureChar)
        ild(hl, .caret_x)
        ld d, (hl)
        add a, d
        ld (hl), a

        jr .input_loop
.handle_bksp:
        ild(hl, (.start_address))
        push ix \ pop bc
        scf \ ccf
        sbc hl, bc
        jr z, .input_loop

        dec ix
        ld a, (ix)
        ld (ix), 0

        pcall(measureChar)
        ild(hl, .caret_x)
        ld d, (hl)
        neg
        add a, d
        ld (hl), a

        icall(.draw_input_area)

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
.draw_input_area:
    ; Draw input area
    push bc
    push hl
    push de
    push af
        ld e, 1
        ld l, 24
        ld bc, 9 * 256 + 94
        pcall(rectOR)

        ld e, 2
        ld l, 25
        ld bc, 7 * 256 + 92
        pcall(rectXOR)

        ; Draw current value
        ld e, 26
        ld d, 3
        ild(hl, (.start_address))
        pcall(drawStr)
    pop af
    pop de
    pop hl
    pop bc
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
