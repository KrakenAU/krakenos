; Constants
STACK_BASE equ 0x90000

; GDT segment selectors
CODE_SEG equ 0x08 ; Offset in GDT for code segment
DATA_SEG equ 0x10 ; Offset in GDT for data segment

[bits 16]
global switch_to_pm
switch_to_pm:
    cli                     ; 1. Disable interrupts
    lgdt [gdt_descriptor]   ; 2. Load GDT
    
    ; 3. Enable protected mode
    mov eax, cr0
    or eax, 0x1             ; Set protected mode bit
    mov cr0, eax
    
    ; 4. Far jump to flush CPU pipeline
    jmp CODE_SEG:init_pm

[bits 32]
init_pm:
    ; 5. Set up segment registers
    mov ax, DATA_SEG
    mov ds, ax
    mov ss, ax
    mov es, ax
    mov fs, ax
    mov gs, ax

    ; 6. Set up stack
    mov ebp, STACK_BASE
    mov esp, ebp

    ; 7. Call main protected mode code
    call BEGIN_PM