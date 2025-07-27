[BITS 16]
[ORG 0x0000]

start:
    mov ax, 0x1000
    mov ds, ax
    mov es, ax
    
    mov ax, 0x0003
    int 0x10
    
    call hide_cursor
    call clear_screen
    call init_confetti
    call fade_in_message
    call play_birthday_song
    
main_loop:
    call update_confetti
    call delay_frame
    jmp main_loop

hide_cursor:
    mov ah, 0x01
    mov cx, 0x2000
    int 0x10
    ret

clear_screen:
    mov ah, 0x06
    mov al, 0
    mov bh, 0x0F
    mov cx, 0
    mov dx, 0x184F
    int 0x10
    ret

init_confetti:
    mov cx, 15
    mov si, confetti_array
    mov di, confetti_timers
    
.init_loop:
    push cx
    
    call get_random
    and al, 0x4F
    mov [si], al
    inc si
    
    call get_random
    and al, 0x1F
    neg al
    mov [si], al
    inc si
    
    call get_random
    and al, 0x0F
    mov [di], al
    inc di
    
    pop cx
    loop .init_loop
    ret

fade_in_message:
    mov word [fade_step], 0
    
.fade_loop:
    mov ah, 0x02
    mov bh, 0
    mov dh, 12
    mov dl, 32
    int 0x10
    
    mov ax, [fade_step]
    cmp ax, 8
    jb .invisible
    
    sub ax, 8
    shr ax, 2
    add al, 0x08
    cmp al, 0x0F
    jbe .show_text
    mov al, 0x0F
    
.show_text:
    mov bl, al
    mov si, birthday_msg
    call print_colored_string
    jmp .continue_fade
    
.invisible:
    mov si, spaces_msg
    mov bl, 0x0F
    call print_colored_string
    
.continue_fade:
    call very_long_delay
    
    inc word [fade_step]
    cmp word [fade_step], 40
    jb .fade_loop
    ret

print_colored_string:
    mov ah, 0x0E
    mov bh, 0
.repeat:
    lodsb
    cmp al, 0
    je .done
    push ax
    push bx
    mov ah, 0x09
    mov cx, 1
    int 0x10
    pop bx
    pop ax
    
    mov ah, 0x03
    int 0x10
    inc dl
    mov ah, 0x02
    int 0x10
    jmp .repeat
.done:
    ret

update_confetti:
    mov cx, 20
    mov si, confetti_array
    mov di, confetti_timers
    
.update_loop:
    push cx
    
    dec byte [di]
    jnz .skip_update
    
    call get_random
    and al, 0x7F
    add al, 80
    mov [di], al
    
    lodsb
    mov dl, al
    lodsb
    mov dh, al
    
    mov ah, 0x02
    mov bh, 0
    int 0x10
    
    mov ah, 0x09
    mov al, ' '
    mov bl, 0x0F
    mov cx, 1
    int 0x10
    
    inc dh
    cmp dh, 25
    jb .draw_particle
    
    call get_random
    and al, 0x4F
    mov dl, al
    mov dh, 0
    
.draw_particle:
    mov [si-1], dh
    mov [si-2], dl
    
    mov ah, 0x02
    mov bh, 0
    int 0x10
    
    call get_random
    and al, 0x07
    add al, 0x09
    mov bl, al
    
    mov ah, 0x09
    mov al, '*'
    mov cx, 1
    int 0x10
    
    jmp .next_particle
    
.skip_update:
    inc si
    inc si
    
.next_particle:
    inc di
    pop cx
    loop .update_loop
    ret

get_random:
    push dx
    mov ax, [random_seed]
    mov dx, 25173
    mul dx
    add ax, 13849
    mov [random_seed], ax
    pop dx
    ret

play_birthday_song:
    mov si, song_data
.play_loop:
    lodsw
    cmp ax, 0
    je .song_done
    call play_note
    jmp .play_loop
.song_done:
    ret

play_note:
    push ax
    push bx
    push cx
    push dx
    
    cmp ax, 0
    je .rest
    
    mov bx, ax
    mov al, 0xB6
    out 0x43, al
    
    mov ax, 1193
    mul bx
    mov bx, ax
    mov ax, 1000
    xor dx, dx
    div bx
    out 0x42, al
    mov al, ah
    out 0x42, al
    
    in al, 0x61
    or al, 3
    out 0x61, al
    
    jmp .delay
    
.rest:
    in al, 0x61
    and al, 0xFC
    out 0x61, al

.delay:
    mov cx, 0x800
.delay_loop:
    nop
    loop .delay_loop
    
    in al, 0x61
    and al, 0xFC
    out 0x61, al
    
    pop dx
    pop cx
    pop bx
    pop ax
    ret

delay_frame:
    mov cx, 0x2000
.delay_loop:
    nop
    loop .delay_loop
    ret

very_long_delay:
    mov cx, 0x8000
.delay_loop:
    push cx
    mov cx, 0x400
.inner_loop:
    nop
    loop .inner_loop
    pop cx
    loop .delay_loop
    ret

birthday_msg db 'HAPPY BIRTHDAY!', 0
spaces_msg db '               ', 0

song_data:
    dw 262, 294, 330, 349, 392, 440, 494
    dw 523, 587, 659, 698, 784, 880, 988
    dw 0

random_seed dw 12345
fade_step dw 0

confetti_array:
    times 45 db 20

confetti_timers:
    times 1 db 2
