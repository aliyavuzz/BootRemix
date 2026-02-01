; FanBeatDriver, for creating notes and remixing with fan in HP pavilion dv6 (and similar builds)
.CODE
EXTERN TestFan:PROC
EXTERN PlayNote:PROC
EXTERN StopNote:PROC
EXTERN FanKick:PROC

; UEFI Offsets
EFI_SYSTEM_TABLE_ConIn           EQU 30h    ; ConIn pointer
EFI_SIMPLE_INPUT_READ_KEY        EQU 8h     ; ReadKeyStroke func

PUBLIC _ModuleEntryPoint
_ModuleEntryPoint PROC
    push    rbp
    mov     rbp, rsp
    sub     rsp, 40h            ; Shadow space + local var
    
    mov     [rbp + 10h], rdx    ; SystemTable hide

main_loop:
    ; -read keyboard 
    mov     rax, [rbp + 10h]            ; SystemTable
    mov     rcx, [rax + EFI_SYSTEM_TABLE_ConIn]
    lea     rdx, [rbp + 20h]            ; EFI_INPUT_KEY 
    mov     rax, [rcx + EFI_SIMPLE_INPUT_READ_KEY]
    call    rax                         ; ReadKeyStroke() call
    
    test    rax, rax
    jnz     main_loop                   ; if no click, loop

    ; keyboard func
    movzx   rax, word ptr [rbp + 22h]   ; UnicodeChar

    ; ESC (0x1B) exit
    cmp     al, 1Bh
    je      end_program

    ; SPACE (0x20) - fan beat :)
    cmp     al, 20h
    jne     check_notes
    call    FanKick
    jmp     main_loop

check_notes:
    ; 'a' -> DO (261 Hz)
    cmp     al, 'a'
    mov     rcx, 261
    je      play_it
    
    ; 's' -> RE (293 Hz)
    cmp     al, 's'
    mov     rcx, 293
    je      play_it

    ; 'd' -> MI (329 Hz)
    cmp     al, 'd'
    mov     rcx, 329
    je      play_it

    ; 'f' -> FA (349 Hz)
    cmp     al, 'f'
    mov     rcx, 349
    je      play_it

    jmp     main_loop ;loop call, obvious

play_it:
    call    PlayNote
    ; a little magic ()
    mov     rcx, 50000h
delay_note: nop
    loop    delay_note
    call    StopNote
    jmp     main_loop

end_program:
    xor     rax, rax
    add     rsp, 40h
    pop     rbp
    ret
_ModuleEntryPoint ENDP
END