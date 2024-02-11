; Intro 64 bytes
; Released on LoveByte 2024.
; by Tygrys / speccy.pl

ROM_PIXELADD: equ $22AA +6

ORGADDR:    equ $8000
XTABLE:     equ ORGADDR + $100 ; X table

    org ORGADDR
; PIXEL table
    db  %10000000
    db  %01000000
    db  %00100000
    db  %00010000
    db  %00001000
    db  %00000100
    db  %00000010
    db  %00000001
;
start:
; init data, X and delta table
    ld  h,a
    ld  bc,XTABLE+191           ; XTABLE, c as counter
_populateXandDelta:
    ld  a,(hl)                  ; source data
    dec hl
    ld  (bc),a                  ; save to XTABLE
    inc b                       ; to DELTA table
    dec hl
    ld  a,(hl)                  ; get random data for DELTA
    and %00000111               ; only 3 bits
    jr  nz,_populateXandDeltaNZ
    inc a
_populateXandDeltaNZ:
    ld  (bc),a                  ; save to DELTA TABLE
    dec b                       ; back to XTABLE
    inc hl                      ; increse source data
    dec c                       ; counter
    jr nz,_populateXandDelta

; main loop
mainloop:
; HL - XTABLE addr
; B - Y
; c = X from (HL)
; D - PIXEL table
; E - temporary
; A - temporary
    ld  d,high ORGADDR          ; high byte add for pixel table

    ld  hl,XTABLE+191
    ld  b,191                   ; counter, Y = 191
loop:
    ; erase old pixel
    ld  c,(hl)                  ; C = X,  B = y

    ; save pointer 2 times
    push    hl
    push    hl

    ld  a,b
    ; IN:  BC - y,x
    ; OUT: HL - vram
    ;       A - bit number
    call    ROM_PIXELADD
    ld  (hl),0                  ;  clear pixels

    ; restore pointer to XTABLE, 1st time
    pop hl
    inc h
    ld  a,(hl)                  ; read delta
    add a,c
    ld  c,a

    ld  a,b
    call    ROM_PIXELADD

    ; put pixel
    ld  e,a
    ld  a,(de)
    ld  (hl),a

    ; restore pointer to XTABLE, 2nd time
    pop hl
    ld  (hl),c                  ; save new X
    dec l                       ; decrese pointer
    djnz loop
    jr  mainloop

end start