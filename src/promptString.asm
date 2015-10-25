;; promptString [GUI]
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
    pop hl \ pop bc \ push bc \ push hl
        ld de, 0x0012
        pcall(drawStr)
        ild(hl, promptText)
        ld de, 0x002B
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
        add a, 2
        ild((.caret_x), a)

        pcall(flushKeys)
.input_loop:
        icall(.draw_input_area)
        icall(.draw_caret)
        pcall(fastCopy)
        icall(getCharacterInput)
        cp '\n'
        ijp(z, .accept)
        or a
        jr nz, .insert_character
        ld a, b
        cp kMODE
        ijp(z, .cancel)
        cp kLeft
        jr z, .left
        cp kRight
        jr z, .right
        jr .input_loop
.left:
        pcall(flushKeys)

        ild(bc, (.start_address))
        push ix \ pop hl
        pcall(cpHLBC)
        jr z, .input_loop

        dec ix

        icall(.erase_caret)
        ld a, (ix)
        pcall(measureChar)
        neg
        ild(hl, .caret_x)
        add (hl)
        cp 2
        ijp(c, .do_scroll_right)
        cp 0xF0
        ijp(nc, .do_scroll_right)
        ild((.caret_x), a)

        jr .input_loop
.right:
        pcall(flushKeys)

        icall(.erase_caret)
        ld a, (ix)
        or a
        jr z, .input_loop

        inc ix

        pcall(measureChar)
        ild(hl, .caret_x)
        add (hl)
        cp 94
        ijp(z, .do_scroll_left)
        ijp(nc, .do_scroll_left)
        ild((.caret_x), a)

        ijp(.input_loop)

.insert_character:
        pcall(flushKeys)
        ; Handle character
        icall(.erase_caret)
        cp '\b'
        ijp(z, .handle_bksp)

        ild(hl, (.current_length))
        ild(bc, (.max_length))
        pcall(cpHLBC)
        ijp(z, .input_loop)
        inc hl
        ild((.current_length), hl)

        ; Insert character
        push ix \ pop hl
        ild(bc, (.start_address))
        scf \ ccf
        sbc hl, bc
        ld b, h \ ld c, l
        ild(hl, (.current_length))
        dec hl
        scf \ ccf
        sbc hl, bc
        ld b, h \ ld c, l
        ld hl, 0
        pcall(cpHLBC)
        jr z, _ ; Skip if no need to shift

        ild(hl, (.start_address))
        ild(de, (.current_length))
        add hl, de
        ex de, hl
        scf \ ccf
        sbc hl, bc
        ex de, hl
        ld d, h \ ld e, l \ dec de
        inc bc
        ex de, hl
        lddr

_:      push af
            ld b, (ix)
            ld (ix), a
            inc ix
            xor a
            cp b
            jr nz, _
            ld (ix), 0
_:      pop af

        ; Advance caret
        pcall(measureChar)
        ild(hl, .caret_x)
        ld d, (hl)
        add a, d
        cp 94
        jr z, .do_scroll_left
        jr nc, .do_scroll_left
        ld (hl), a
        ijp(.input_loop)
.do_scroll_left:
        ld a, (ix + -1)
        pcall(measureChar)
        ild(hl, .left_offset)
        add a, (hl)
        ld (hl), a
        ijp(.input_loop)
.do_scroll_right:
        ld b, a
        ld a, 2
        ild((.caret_x), a)
        sub b
        ild(hl, .left_offset)
        neg
        add a, (hl)
        ld (hl), a
        ijp(.input_loop)
.handle_bksp:
        ild(hl, (.start_address))
        push ix \ pop bc
        scf \ ccf
        sbc hl, bc
        ijp(z, .input_loop)

        dec ix
        ld a, (ix)
        push af

            ild(hl, (.current_length))
            dec hl
            ild((.current_length), hl)

            push ix \ pop hl
            ld d, h \ ld e, l
            inc hl
            push hl
                ild(bc, (.start_address))
                push ix \ pop hl
                scf \ ccf
                sbc hl, bc
                ild(bc, (.current_length))
                add hl, bc
                ld b, h \ ld c, l
            pop hl
            inc bc
            ldir

        pop af
        pcall(measureChar)
        neg
        ild(hl, .caret_x)
        add (hl)
        cp 2
        ijp(c, .do_scroll_right)
        cp 0xF0
        ijp(nc, .do_scroll_right)
        ild((.caret_x), a)

        ijp(.input_loop)
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
        ld e, 0
        ld l, 24
        ld bc, 9 * 256 + 96
        pcall(rectAND)

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
        ild(a, (.left_offset))
        neg
        add a, d \ ld d, a
.input_area_loop:
        ld a, d
        cp 0x80
        jr c, _
        ld a, (hl)
        inc hl
        pcall(measureChar)
        add a, d
        ld d, a
        jr .input_area_loop
_:      pcall(drawStr)

        ld e, 0
        ld l, 24
        ld bc, 9 * 256 + 1
        pcall(rectAND)

        ld e, 95
        ld l, 24
        ld bc, 9 * 256 + 1
        pcall(rectAND)
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
.left_offset:
    .db 0
