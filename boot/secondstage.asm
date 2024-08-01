[org 0x7e00]
[bits 16]

second_stage_start:
    ; Print message
    mov si, MSG_SECOND_STAGE
    call print
    call print_nl

    ; Switch to protected mode
    call switch_to_pm

%include "boot/switch_pm.asm"
%include "boot/gdt.asm"
%include "boot/32bit_print.asm"
%include "boot/print.asm"
                                                                              
[bits 32]
read_disk:
    pushad
    mov esi, eax        ; Save LBA in ESI

    mov eax, ecx
    mov ecx, 256
    mul ecx
    mov ecx, eax        ; ECX = number of words to read

    mov edx, 0x1F6      ; Port to send drive and bit 24 - 27 of LBA
    mov al, 0xE0        ; Drive 0, LBA mode
    out dx, al

    mov edx, 0x1F2      ; Sector count port
    mov al, cl          ; Number of sectors
    out dx, al

    mov edx, 0x1F3      ; Sector number port
    mov eax, esi        ; LBA to read from
    out dx, al

    mov edx, 0x1F4      ; Cylinder low port
    mov eax, esi
    shr eax, 8
    out dx, al

    mov edx, 0x1F5      ; Cylinder high port
    mov eax, esi
    shr eax, 16
    out dx, al

    mov edx, 0x1F7      ; Command port
    mov al, 0x20        ; Read with retry
    out dx, al

.loop:
    in al, dx
    test al, 8          ; Check if sector buffer requires servicing
    jz .loop

    mov edx, 0x1F0      ; Data port
    mov ecx, 256        ; Read 256 words
    rep insw            ; Read a word

    mov edx, 0x1F7      ; Command port
    in al, dx
    test al, 8          ; Check if sector buffer requires servicing
    jnz .loop

    popad
    ret
    
BEGIN_PM:
    call clear_screen_pm

    mov esi, MSG_PROT_MODE 
    call print_string_pm

    mov esi, MSG_LOADING_KERNEL
    call print_string_pm

    ; Load kernel
    mov eax, 3          ; Start reading from the 3rd sector (0-based)
    mov ebx, 0x100000   ; Load kernel at 1MB
    mov ecx, 16         ; Read 16 sectors (8KB, adjust if needed)
    call read_disk

    mov esi, MSG_JUMPING_KERNEL
    call print_string_pm

    ; Jump to kernel
    jmp 0x100000

MSG_LOADING_KERNEL db 'Loading kernel...', 0
MSG_JUMPING_KERNEL db 'Jumping to kernel...', 0
MSG_SECOND_STAGE db 'Second stage loaded successfully', 0
MSG_PROT_MODE    db 'Successfully landed in 32-bit Protected Mode', 0
times 1024 - ($ - $$) db 0