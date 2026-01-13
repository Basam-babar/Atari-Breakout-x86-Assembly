[org 0x0100]
jmp intro_screen


oldisr: dd 0
oldtimer: dd 0

ballx: dw 40
bally: dw 15
balldx: db 1
balldy: db 1

paddle: dw 35
score: dw 0
delay: db 0
lives: db 3         
game_time: dw 0      
sound_flag: db 0     

; 3 rows of 6 bricks
brick_status: db 1,1,1,1,1,1
              db 1,1,1,1,1,1
              db 1,1,1,1,1,1


intro_screen:
    call clrscr
    mov ax, 0xb800
    mov es, ax
    
    
    mov di, 1820       
    
   
    mov si, atari_text
    mov cx, 14          
    mov ah, 0x0E      
draw_atari:
    lodsb
    stosw
    loop draw_atari
    
    ; Wait for any key
    mov ah, 0
    int 0x16
    
    ; Continue to game
    jmp start


beep:
    push ax
    push cx
    in al, 61h
    or al, 3
    out 61h, al
    mov cx, 3000
sound_delay:
    loop sound_delay
    in al, 61h
    and al, 0xFC
    out 61h, al
    pop cx
    pop ax
    ret

clrscr:
    push es
    push ax
    push di
    push cx
    mov ax, 0xb800
    mov es, ax
    xor di, di
    mov ax, 0x0720
    mov cx, 2000
    rep stosw
    pop cx
    pop di
    pop ax
    pop es
    ret

; PRinting score at top center
print_score:
    push es
    push ax
    push di
    push bx
    push cx
    push dx
    mov ax, 0xb800
    mov es, ax
    
    ; Clear score area
    mov di, 70
    mov cx, 10
    mov ax, 0x0720
clear_score:
    stosw
    loop clear_score
    
    ; Print score
    mov ax, [score]
    mov di, 72
    mov bx, 10
    mov cx, 0
    
score_loop1:
    xor dx, dx
    div bx
    push dx
    inc cx
    test ax, ax
    jnz score_loop1
    
score_loop2:
    pop dx
    add dl, '0'
    mov dh, 0x07
    mov [es:di], dx
    add di, 2
    loop score_loop2
    
  
    mov di, 150
    mov al, 'L'
    mov ah, 0x07
    mov [es:di], ax
    mov al, ':'
    mov [es:di+2], ax
    mov al, [lives]
    add al, '0'
    mov [es:di+4], ax
    
   
    mov di, 160
    mov ax, [game_time]
    mov bx, 10
    mov cx, 0
    
timer_loop1:
    xor dx, dx
    div bx
    push dx
    inc cx
    test ax, ax
    jnz timer_loop1
    
timer_loop2:
    pop dx
    add dl, '0'
    mov dh, 0x07
    mov [es:di], dx
    add di, 2
    loop timer_loop2
    
    pop dx
    pop cx
    pop bx
    pop di
    pop ax
    pop es
    ret


draw_bricks:
    push es
    push ax
    push di
    push si
    push cx
    push bx
    mov ax, 0xb800
    mov es, ax
    mov si, 0
    
brick_loop:
    cmp si, 18
    jge bricks_done
    
    cmp byte [brick_status + si], 1 ; checks for bricks status 
    jne next_brick
    
    
    mov ax, si
    mov bl, 6
    div bl
    
    
    ; row starts at 4 and 2 lines apart for each
    movzx bx, al
    imul bx, 320      
    add bx, 640       
    ; Column start at col 4 each brick with 2 gap
    movzx ax, ah
    imul ax, 12       ; 10 w + 2 gap
    add ax, 4         ; Start position
    
    ;screen
    mov di, bx
    add di, ax
    add di, ax        
    ; Set color by row
    cmp si, 6
    jb red_brick
    cmp si, 12
    jb green_brick
    mov ax, 0x1158    ; Blue brick
    jmp draw_brick
red_brick:
    mov ax, 0x4458    ; Red brick
    jmp draw_brick
green_brick:
    mov ax, 0x2258    ; Green brick

draw_brick:
    mov cx, 10        
    rep stosw
    
next_brick:
    inc si
    jmp brick_loop
    
bricks_done:
    pop bx
    pop cx
    pop si
    pop di
    pop ax
    pop es
    ret

; clearing a brick
clear_brick:
    push es
    push ax
    push di
    push cx
    push bx
    mov ax, 0xb800
    mov es, ax
    
    ; calculate the position brick
    mov ax, si
    mov bl, 6
    div bl
    
    
   ;row
    movzx bx, al
    imul bx, 320
    add bx, 640
    
   ;col
    movzx ax, ah
    imul ax, 12
    add ax, 4
    
  
    mov di, bx
    add di, ax
    add di, ax
    
    ; clear
    mov ax, 0x0720
    mov cx, 10
    rep stosw
    
    pop bx
    pop cx
    pop di
    pop ax
    pop es
    ret


draw_paddle:
    push es
    push ax
    push di
    push cx
    mov ax, 0xb800
    mov es, ax
    
   ; clearing the paddle line (makintn it move)a bit bugged 
    mov di, 3680
    mov ax, 0x0720
    mov cx, 80
    rep stosw
    
   
    mov di, 3680
    mov ax, [paddle]
    ; finally the paddle remains
    cmp ax, 0
    jge paddle_ok1
    mov ax, 0
paddle_ok1:
    ; finally the paddle remains
    cmp ax, 70
    jle paddle_ok2
    mov ax, 70
paddle_ok2:
    mov [paddle], ax  
    
    shl ax, 1
    add di, ax
    mov ax, 0x705F  
    mov cx, 10        
    rep stosw
    
    pop cx
    pop di
    pop ax
    pop es
    ret


draw_ball:
    push es
    push ax
    push di
    mov ax, 0xb800
    mov es, ax
    
    mov ax, [bally]
    mov bx, 160
    mul bx
    mov di, ax
    mov ax, [ballx]
    shl ax, 1
    add di, ax
    mov word [es:di], 0x0E2A 
    
    pop di
    pop ax
    pop es
    ret

clear_ball:
    push es
    push ax
    push di
    mov ax, 0xb800
    mov es, ax
    
    mov ax, [bally]
    mov bx, 160
    mul bx
    mov di, ax
    mov ax, [ballx]
    shl ax, 1
    add di, ax
    mov word [es:di], 0x0720  
    
    pop di
    pop ax
    pop es
    ret


check_brick_collision:
    push si
    push ax
    push bx
    push cx
    push dx
    
   ; checking ball pos relative to brick for col
    cmp word [bally], 4
    jb no_brick_hit
    cmp word [bally], 9
    ja no_brick_hit
    
    ; check all bricks to find which hit
    mov si, 0
check_all_bricks:
    cmp si, 18
    jae no_brick_hit
    
   
    cmp byte [brick_status + si], 0
    je next_brick_check
    
    
    mov ax, si
    mov bl, 6
    div bl
    
    
 
    movzx bx, al     
    imul bx, 2        ; 2 l per r
    add bx, 4         ; start at row 4
    
    movzx cx, ah      ; column  
    imul cx, 12      
    add cx, 4         ; start at column 4
   ; brick boundry  
    
    mov dx, cx
    add dx, 9         ; right edge
    
    ; ball is  in brick boundry
    mov ax, [ballx]
    cmp ax, cx
    jb next_brick_check
    cmp ax, dx
    ja next_brick_check
    
    mov ax, [bally]
    cmp ax, bx
    jb next_brick_check
    add bx, 1         ; brick is 2 lines high
    cmp ax, bx
    ja next_brick_check
    
   
    mov byte [brick_status + si], 0
    add word [score], 10
    call print_score
    
    ; clear the hit brick 
    call clear_brick
    

    call beep
    
    ;FINALLY and screw this 
    mov ax, [ballx]
    mov bx, [bally]
    
   
    neg byte [balldy]
    
    jmp brick_hit_done
    
next_brick_check:
    inc si
    jmp check_all_bricks
    
no_brick_hit:
    pop dx
    pop cx
    pop bx
    pop ax
    pop si
    ret
    
brick_hit_done:
    pop dx
    pop cx
    pop bx
    pop ax
    pop si
    ret


move_ball:
    call clear_ball
    
  
    mov al, [balldx]
    cbw
    add [ballx], ax
    
    mov al, [balldy]
    cbw
    add [bally], ax
    
   ; lft wall
    cmp word [ballx], 0
    jg check_right_wall
    mov word [ballx], 1
    mov byte [balldx], 1
    call beep      ; NEW: Sound for wall hit
    jmp check_vertical
    
check_right_wall:
    ; rght wall
    cmp word [ballx], 79
    jl check_vertical
    mov word [ballx], 78
    mov byte [balldx], -1
    call beep      ; NEW: Sound for wall hit
    jmp check_vertical
    
check_vertical:
    ; top collisison
    cmp word [bally], 1
    jg check_paddle_coll
    mov word [bally], 1
    mov byte [balldy], 1
    call beep      ; NEW: Sound for ceiling hit
    jmp check_bricks_coll
    
check_paddle_coll:
    
    cmp word [bally], 22
    jl check_bricks_coll
    cmp word [bally], 23
    jg check_bricks_coll
    
    ; ball is in paddle range or not 
    mov ax, [ballx]
    mov bx, [paddle]
    
  
    cmp bx, 0
    jge paddle_check1
    mov bx, 0
paddle_check1:
    cmp bx, 70
    jle paddle_check2
    mov bx, 70
paddle_check2:
    
   
    cmp ax, bx
    jb check_bricks_coll
    add bx, 9
    cmp ax, bx
    ja check_bricks_coll
   
    mov word [bally], 20  
    mov byte [balldy], -1
    call beep     
    
   ; variatution 
    mov ax, [ballx]
    sub ax, [paddle]
    cmp ax, 3
    jl left_bounce
    cmp ax, 6
    jg right_bounce
    jmp check_bricks_coll
    
left_bounce:
    mov byte [balldx], -1
    jmp check_bricks_coll
    
right_bounce:
    mov byte [balldx], 1
    jmp check_bricks_coll
    
check_bricks_coll:
    call check_brick_collision
    
    ; reset ball if it goes below paddle
    cmp word [bally], 24
    jl ball_done
    
   
    dec byte [lives]
    call print_score
    call beep    
    
    ; Check game over
    cmp byte [lives], 0
    jle game_over
    
    ; Reset ball position
    mov word [ballx], 30
    mov word [bally], 10
    mov byte [balldx], 1
    mov byte [balldy], 1
    
ball_done:
    call draw_ball
    ret

game_over:
    ; Restore interrupts
    xor ax, ax
    mov es, ax
    mov ax, [oldisr]
    mov bx, [oldisr+2]
    cli
    mov [es:9*4], ax
    mov [es:9*4+2], bx
    mov ax, [oldtimer]
    mov bx, [oldtimer+2]
    mov [es:8*4], ax
    mov [es:8*4+2], bx
    sti
    
    call clrscr
    mov ax, 0xb800
    mov es, ax
    
    ; Show GAME OVER
    mov di, 1980
    mov si, game_over_msg
    mov cx, 9
    mov ah, 0x0C
game_over_loop:
    lodsb
    stosw
    loop game_over_loop
    
    ; Wait for key
    mov ah, 0
    int 0x16
    
    jmp exit

kbisr:
    push ax
    in al, 0x60
    
   
    cmp al, 0x4B
    jne check_right_key
    cmp word [paddle], 1
    jle kbdone
    sub word [paddle], 3
    ;paddle dont go less than 0
    cmp word [paddle], 0
    jge paddle_left_ok
    mov word [paddle], 0
paddle_left_ok:
    call draw_paddle
    jmp kbdone
    
check_right_key:
  
    cmp al, 0x4D
    jne kbdone
    cmp word [paddle], 69
    jge kbdone
    add word [paddle], 3
    ; paddle no more than 70
    cmp word [paddle], 70
    jle paddle_right_ok
    mov word [paddle], 70
paddle_right_ok:
    call draw_paddle
    
kbdone:
    mov al, 0x20
    out 0x20, al
    pop ax
    iret


timer:
    push ax
    inc byte [delay]
    cmp byte [delay], 2
    jb timerdone
    mov byte [delay], 0
    call move_ball
    
timerdone:
    
    inc byte [sound_flag]
    cmp byte [sound_flag], 18
    jb skip_timer
    mov byte [sound_flag], 0
    inc word [game_time]
    call print_score
    
skip_timer:
    mov al, 0x20
    out 0x20, al
    pop ax
    jmp far [cs:oldtimer]

check_win:
    mov cx, 18
    mov si, 0
winloop:
    cmp byte [brick_status + si], 1
    je nowin
    inc si
    loop winloop
    mov ax, 1
    ret
nowin:
    mov ax, 0
    ret

show_win:
    
    xor ax, ax
    mov es, ax
    mov ax, [oldisr]
    mov bx, [oldisr+2]
    cli
    mov [es:9*4], ax
    mov [es:9*4+2], bx
    mov ax, [oldtimer]
    mov bx, [oldtimer+2]
    mov [es:8*4], ax
    mov [es:8*4+2], bx
    sti
    
    ; Show win message and stay on it
    call clrscr
    mov ax, 0xb800
    mov es, ax
  
    mov di, 1970        
    mov si, winmsg
    mov cx, 21        
    mov ah, 0x0A
winloop2:
    lodsb
    stosw
    loop winloop2
    
    ; Wait for key
    mov ah, 0
    int 0x16
    
    jmp exit

start:
   
    xor ax, ax
    mov es, ax
    
    mov ax, [es:9*4]
    mov [oldisr], ax
    mov ax, [es:9*4+2]
    mov [oldisr+2], ax
    mov ax, [es:8*4]
    mov [oldtimer], ax
    mov ax, [es:8*4+2]
    mov [oldtimer+2], ax
    
    cli
    mov word [es:9*4], kbisr
    mov [es:9*4+2], cs
    mov word [es:8*4], timer
    mov [es:8*4+2], cs
    sti
    
   
    call clrscr
    call print_score
    call draw_bricks
    call draw_paddle
    call draw_ball
    
gameloop:
    ;win checling ie brick log end for b en
    call check_win
    cmp ax, 1
    je show_win
    
    ; Check if lives are gone
    cmp byte [lives], 0
    jle game_over
    
   
    mov cx, 10000
delayloop:
    loop delayloop
    jmp gameloop

exit:
    
    xor ax, ax
    mov es, ax
    mov ax, [oldisr]
    mov bx, [oldisr+2]
    cli
    mov [es:9*4], ax
    mov [es:9*4+2], bx
    mov ax, [oldtimer]
    mov bx, [oldtimer+2]
    mov [es:8*4], ax
    mov [es:8*4+2], bx
    sti
  
    mov ax, 0x4c00
    int 0x21



winmsg: db '~<REQUIEM AETAERNAM>~'
atari_text: db 'ATARI BREAKOUT'
game_over_msg: db 'GAME OVER'