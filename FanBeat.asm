; FanBeat.asm for HP Pavilion dv6 
; percussion with fan and 8 bit computer music

.CODE

; hardware locations
EC_SC       EQU 66h     ; Status/Command port 
EC_DATA     EQU 62h     ; data port 
EC_RD       EQU 80h     ; Read command 
EC_WR       EQU 81h     ; Write ccommand 
EC_IBF      EQU 02h     ; Input Buffer Full biti 
EC_OBF      EQU 01h     ; Output Buffer Full biti 

; hp dv6 fan registers
FAN_REG1    EQU 0B0h    ; fan speed value (00-FF) 
FAN_REG2    EQU 0B1h    ; bytw to control fan (0Dh)

;fan speed values
FAN_OFF     EQU 00h
FAN_LOW     EQU 40h
FAN_MED     EQU 80h
FAN_HIGH    EQU 0C0h
FAN_MAX     EQU 0FFh

;pc speaker locations
PIT_CTRL    EQU 43h
PIT_CHAN2   EQU 42h
SPEAKER_P   EQU 61h

; EC funcs

EC_WaitReady PROC
    push    rcx
    mov     rcx, 10000h
wait_loop:
    mov     dx, EC_SC
    in      al, dx
    test    al, EC_IBF
    jz      ready
    loop    wait_loop
ready:
    pop     rcx
    ret
EC_WaitReady ENDP

EC_WriteByte PROC
    push    rcx
    call    EC_WaitReady
    mov     dx, EC_SC
    mov     al, EC_WR
    out     dx, al
    call    EC_WaitReady
    mov     dx, EC_DATA
    mov     al, cl              ; reg loc
    out     dx, al
    call    EC_WaitReady
    mov     dx, EC_DATA
    mov     al, ch              ; data byte
    out     dx, al
    pop     rcx
    ret
EC_WriteByte ENDP

; fan speed manage
; Input: CL = speed (0-255)
PUBLIC SetFanSpeed
SetFanSpeed PROC
    push    rcx
    push    rdx
    mov     ch, cl              ; speed value
    mov     cl, FAN_REG1
    call    EC_WriteByte
    mov     cl, FAN_REG2
    mov     ch, 0Dh            
    call    EC_WriteByte
    pop     rdx
    pop     rcx
    ret
SetFanSpeed ENDP


; 8 bit speaker functsions

; start with a frequence
; Input: RCX = Frekans (Hz)
PUBLIC PlayNote
PlayNote PROC
    push    rax
    push    rdx
    push    rcx
    mov     rax, 1193180        ; PIT frequence
    xor     rdx, rdx
    div     rcx
    mov     rcx, rax
    mov     al, 0B6h
    out     PIT_CTRL, al
    mov     al, cl
    out     PIT_CHAN2, al
    mov     al, ch
    out     PIT_CHAN2, al
    in      al, SPEAKER_P
    or      al, 03h
    out     SPEAKER_P, al
    pop     rcx
    pop     rdx
    pop     rax
    ret
PlayNote ENDP

; stop the music
PUBLIC StopNote
StopNote PROC
    in      al, SPEAKER_P
    and     al, 0FCh
    out     SPEAKER_P, al
    ret
StopNote ENDP

; Percussion (best part)

;(Kick Drum effect)
PUBLIC FanKick
FanKick PROC
    push    rcx
    mov     cl, FAN_MAX
    call    SetFanSpeed
    ; short kick duration
    mov     rcx, 80000h
k_del: nop
    loop    k_del
    mov     cl, FAN_OFF
    call    SetFanSpeed
    pop     rcx
    ret
FanKick ENDP


PUBLIC Delay10ms
Delay10ms PROC
    push    rcx
    mov     rcx, 150000h
delay_loop:
    nop
    loop    delay_loop
    pop     rcx
    ret
Delay10ms ENDP

;empty test function in start

PUBLIC TestFan
TestFan PROC
    ret
TestFan ENDP

END