;; showMessage [GUI]
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
                    ld de, 3 * 256 + 18
                    ild(hl, exclamationSprite1)
                    pcall(putSpriteOR)
                    ld e, 26
                    ild(hl, exclamationSprite2)
                    pcall(putSpriteOR)
.skipIcon:
        pop bc \ pop hl \ pop de \ pop af \ push hl \ push bc \ push af \ push de
                    ; For now we'll hardcode the location of the text, but if wider icons get
                    ; implemented the text's X coordinate needs to be calculated (or pre-stored).
                    ld de, 11 * 256 + 18 ; d = 26, e = 18 (coords)
                    ld bc, (96 - 0) * 256 + 37 ; margins
                    ld a, d ; margin
                    pcall(wrapStr)

                    ; Draw all the options
                    ld de, 15 * 256 + 37
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
                        ld d, 11
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

;; showError [GUI]
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

;; showErrorAndQuit [GUI]
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
