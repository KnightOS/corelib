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

castlePath:
    .db "/bin/launcher", 0
threadlistPath:
    .db "/bin/switcher", 0
