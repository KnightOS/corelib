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
            ild((error_code), a)
            ijp(nz, .isKEXCfail)

            ld bc, 5
            pcall(malloc)
            ild((error_code), a)
            ijp(nz, .isKEXCfail)

            dec bc
            pcall(streamReadBuffer)
            ild((error_code), a)
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
        ild((error_code), a)
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
        ld (error_code), a
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
    ild(a, (error_code))
    ijp(po, _)
    ei
_:  or 1
    ret

.end:
    pop af
    ild(a, (error_code))
    ijp(po, _)
    ei
_:  cp a
    ret

open_returnPoint:
    ild(de, castlePath)
    pcall(launchProgram)
    pcall(killCurrentThread)

magicPath:
    .db "/etc/magic", 0
extensionsPath:
    .db "/etc/extensions", 0
editorPath:
    .db "/bin/editor", 0
kexcString:
    .db "KEXC", 0
error_code:
    .db 0
