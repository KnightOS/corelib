;; wordWrap [GUI]
;;  Similar to the kernel's wrapStr function, but break at words, not characters.
;; Inputs:
;;  HL: String pointer
;;  IY: Screen buffer
;;  A: Left margin
;;  D, E: X, Y
;;  B, C: X Limit, Y Limit
;; Outputs:
;;  D, E: Advanced to position of the end of the string
;;  HL: Pointer to null terminator or next character that would have been drawn if the string hadn't run off-screen.
;; Notes:
;;  This function destroys shadow registers.
wordWrap:
    push af
    push ix
        ; Variables:
        ; B  = xLimit   C = width   | B' = margin   C' = yLimit
        ; DE = lastSpace            | D' = x        E' = y
        ; HL = startLine            | HL' = startLine
        ; IX = nextChar
        push bc
        push de
        push hl
            ld b, a     ; Copy margin to B
            exx         ; Save drawing variables and swich to text processing variables
        pop hl
        pop de
        pop bc

        ld c, d             ; width = X
        push hl \ pop ix    ; currentChar = startLine
        push hl \ pop de    ; lastSpace = startLine

.loop:
        ; If char is null, print line and exit
        ld a, (ix)
        or a
        jr nz, _
        push hl
            exx
        pop hl
        pcall(drawStr)
        push ix \ pop hl    ; copy terminator to hl
        jr .exit

_:      ; If char is a newline, print line and move to next line
        cp '\n'
        jr nz, _
        push hl
            exx
        pop hl
        push bc
            push ix \ pop bc
            icall(printRange)
            inc ix
            jr .nextLine

_:      ; If char is whitespace, record its position
        cp ' '
        jr nz, _
        push ix \ pop de
_:      cp '\t'
        jr nz, _
        push ix \ pop de

_:      ; Move on if char doesn't overflow line
        pcall(measureChar)
        add a, c
        ld c, a
        cp b
        jr nc, _
        inc ix
        jr .loop

_:      ; If there have been no spaces on this line,
        ; print everything up to the current char
        ld a, d
        cp h
        jr nz, _
        ld a, e
        cp l
        jr nz, _
        push hl
            exx
        pop hl
        push bc
            push ix \ pop bc
            icall(printRange)
            jr .nextLine

_:      ; Print everything up to the last space
        push de \ pop ix
        push hl
            exx
        pop hl
        push bc             ; save margin
            push ix \ pop bc
            inc bc
            icall(printRange)
            inc ix              ; move to next char
.nextLine:
        pop bc              ; restore margin
        pcall(newLine)      ; move cursor down
        ; Break if y coordinate is below lower limit
        ld a, e
        cp c
        jr nc, .exit
        push de
            exx
        pop de
        ld c, d             ; copy width
        push ix \ pop hl    ; reset startLine...
        push ix \ pop de    ; ...and lastSpace
        jr .loop

.exit:
    pop ix
    pop af
    ret

; printRange
; Similar to kernel function drawStr
; except takes a pointer to the end of the string instead of checking for zero-delimination
; Inputs:
;  IY: Screen buffer
;  HL: Start of string
;  BC: End of string
;  D, E: X, Y
; Outputs:
;  D, E: Advanced to position of the end of the string
printRange:
    push af
_:      ; If HL < BC
        ld a, b
        cp h
        jr c, ++_
        jr nz, _
        ld a, c
        cp l
        jr c, ++_
        jr z, ++_
        ; Draw char
_:      ld a, (hl)
        pcall(drawChar)
        inc hl
        jr --_
_:  pop af
    ret
