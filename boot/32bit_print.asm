[bits 32]

VIDEO_MEMORY equ 0xb8000
COLS equ 80
ROWS equ 25

global print_string_pm, clear_screen_pm, set_cursor_pm, scroll_screen_pm

section .data
cursor_pos dd 0

section .text

print_string_pm:
    pushad
    mov edi, [cursor_pos]
    shl edi, 1              ; Multiply by 2 for video memory offset
    add edi, VIDEO_MEMORY
    cld
.loop:
    lodsb
    test al, al
    jz .done
    cmp al, 10
    je .newline
    mov ah, 0x0F            ; White text on black background
    stosw
    inc dword [cursor_pos]
    cmp dword [cursor_pos], COLS * ROWS
    jl .loop
    call scroll_screen_pm
    mov edi, (ROWS - 1) * COLS * 2 + VIDEO_MEMORY
    jmp .loop
.newline:
    call new_line
    mov edi, [cursor_pos]
    shl edi, 1
    add edi, VIDEO_MEMORY
    jmp .loop
.done:
    popad
    ret

clear_screen_pm:
    pushad
    xor eax, eax
    mov ecx, COLS * ROWS
    mov edi, VIDEO_MEMORY
    rep stosd
    mov [cursor_pos], eax
    popad
    ret

set_cursor_pm:
    mov [cursor_pos], eax
    ret

scroll_screen_pm:
    pushad
    mov esi, VIDEO_MEMORY + COLS * 2
    mov edi, VIDEO_MEMORY
    mov ecx, (ROWS - 1) * COLS
    rep movsd
    mov ecx, COLS
    xor eax, eax
    rep stosd
    sub dword [cursor_pos], COLS
    jns .done
    mov dword [cursor_pos], 0
.done:
    popad
    ret

new_line:
    push eax
    mov eax, [cursor_pos]
    xor edx, edx
    mov ebx, COLS
    div ebx
    inc eax
    mul ebx
    mov [cursor_pos], eax
    pop eax
    ret