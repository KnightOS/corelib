;; showMenu [GUI]
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
        push bc
        push hl
            ld b, a
            ild(hl, .numeric_input_keys)
            pcall(strchr)
            jr z, .handle_numeric_selection
        pop hl
        pop bc
        jr .input_loop
.handle_numeric_selection:
            ild(bc, .numeric_input_keys)
            scf \ ccf
            sbc hl, bc
            ld a, l
        pop hl
        pop bc
    pop hl \ push hl
        push bc
            ld c, (hl)
            cp c
        pop bc
        jr z, .input_loop
        jr nc, .input_loop
    pop hl
    pop bc
    pop de
    inc sp \ inc sp ; pop af
    ret
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
.numeric_input_keys:
    .db k1, k2, k3, k4, k5, k6, k7, k8, k9, 0

#include "src/errors.asm"
