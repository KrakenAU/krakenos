; KrakenOS Bootloader
[org 0x7c00]
[bits 16]

    ; Set up stack
    xor ax, ax
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x7C00

    ; Load second stage
    mov ah, 0x02        ; BIOS read sector function
    mov al, 2           ; Number of sectors to read (adjust if needed)
    mov ch, 0           ; Cylinder number
    mov cl, 2           ; Sector number (1 is bootloader, so start at 2)
    mov dh, 0           ; Head number
    mov bx, 0x7E00      ; Load sectors right after bootloader
    int 0x13            ; BIOS interrupt
    jc disk_error       ; Jump if error (carry flag set)

    ; Clear screen
    call clear_screen

    ; Print welcome message
    mov si, MSG_WELCOME
    call print_centered

    ; Jump to second stage
    jmp 0x7E00

disk_error:
    mov si, DISK_ERROR_MSG
    call print
    jmp $

%include "boot/print.asm"

; Messages
MSG_WELCOME     db 'Welcome to NiggaOS Bootloader', 0
DISK_ERROR_MSG  db 'Disk read error!', 0

; Padding and magic number
times 510 - ($ - $$) db 0
dw 0xaa55