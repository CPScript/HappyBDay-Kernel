[BITS 16]
[ORG 0x7C00]

start:
    cli
    xor ax, ax
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x7C00
    sti
    
    mov si, loading_msg
    call print_string
    
    mov bx, 0x1000
    mov es, bx
    xor bx, bx
    
    mov ah, 0x02
    mov al, 1
    mov ch, 0
    mov cl, 2
    mov dh, 0
    mov dl, 0x00
    int 0x13
    
    jc disk_error
    
    mov si, success_msg
    call print_string
    
    jmp 0x1000:0x0000

disk_error:
    mov si, error_msg
    call print_string
    jmp $

print_string:
    mov ah, 0x0E
    mov bh, 0
.repeat:
    lodsb
    cmp al, 0
    je .done
    int 0x10
    jmp .repeat
.done:
    ret

loading_msg db 'Loading kernel...', 13, 10, 0
success_msg db 'Kernel loaded, jumping...', 13, 10, 0
error_msg db 'Disk read error!', 13, 10, 0

times 510-($-$$) db 0
dw 0xAA55
