; Print string pointed to by SI, with optional newline if AH is non-zero
print:
    push bx
    mov bl, ah
    mov ah, 0x0e
    xor bh, bh
.loop:
    lodsb
    test al, al
    jz .done
    int 0x10
    jmp .loop
.done:
    test bl, bl
    jz .exit
    call print_nl
.exit:
    pop bx
    ret

; Print newline
print_nl:
    mov ax, 0x0E0A
    int 0x10
    mov al, 0x0D
    int 0x10
    ret

; Print single character in AL
print_char:
    mov ah, 0x0e
    xor bh, bh
    int 0x10
    ret

; Print hexadecimal value in DX
print_hex:
    push cx
    mov cx, 4
.loop:
    rol dx, 4
    mov al, dl
    and al, 0x0F
    add al, '0'
    cmp al, '9'
    jle .print
    add al, 7
.print:
    call print_char
    loop .loop
    pop cx
    ret

; Print decimal value in AX
print_dec:
    push bx
    push cx
    mov bx, 10
    xor cx, cx
.divide:
    xor dx, dx
    div bx
    push dx
    inc cx
    test ax, ax
    jnz .divide
.print:
    pop ax
    add al, '0'
    call print_char
    loop .print
    pop cx
    pop bx
    ret

; Clear screen
clear_screen:
    mov ax, 0x0003
    int 0x10
    ret

; Print centered string pointed to by SI
print_centered:
    push cx
    call str_len
    mov ax, 80
    sub ax, cx
    shr ax, 1
    mov cx, ax
    mov al, ' '
.pad_loop:
    call print_char
    loop .pad_loop
    call print
    pop cx
    ret

; Get string length (pointed to by SI) in CX
str_len:
    push ax
    push si
    xor cx, cx
.loop:
    lodsb
    test al, al
    jz .done
    inc cx
    jmp .loop
.done:
    pop si
    pop ax
    ret