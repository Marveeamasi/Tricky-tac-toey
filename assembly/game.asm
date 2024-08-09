section .bss
game_position_pointer resb 9
key resb 1

section .data
new_line db 10
nl_size equ $-new_line

game_draw db "_|_|_", 10 
          db "_|_|_", 10
          db "_|_|_", 10, 0
gd_size equ $-game_draw

win_flag db 0

player db "0", 0
p_size equ $-player

game_over_message db "GAME OVER", 10, 0
gom_size equ $-game_over_message

game_start_message db "TICKY TAC TOEY"
gsm_size equ $-game_start_message

player_message db "PLAYER ", 0
pm_size equ $-player_message

win_message db " WON!", 0
wm_size equ $-win_message

type_message db "PLEASE ENTER A POSITION ON THE BOARD: ", 0
tm_size equ $-type_message

clear_screen_ASCII_escape db 27,"[H",27,"[2J"      ; <ESC> [H  <ESC>  [2J
cs_size equ $-clear_screen_ASCII_escape

section .text 
global _start 

_start:
call set_game_pos_pointer

main_loop:
call clear_screen

mov rsi, game_start_message
mov rdx, gsm_size
call print

mov rsi, new_line
mov rdx, nl_size
call print

mov rsi, player_message
mov rdx, pm_size
call print

mov rsi, player
mov rdx, p_size
call print

mov rsi, new_line
mov rdx, nl_size
call print

mov rsi, game_draw
mov rdx, gd_size
call print

mov rsi, new_line
mov rdx, nl_size
call print

mov rsi, type_message
mov rdx, tm_size
call print

call read_keyboard               ;  reading the position that the user will pass

mov al, [key]
sub al, 49                      


call update_draw

call check

cmp byte[win_flag], 1
je game_over

call change_player

jmp main_loop

change_player:

mov si, player
xor byte[si], 1  ; more like an XOR swap :)

ret

print:
mov rax, 1
mov rdi, 1
syscall
ret

read_keyboard:
mov rax, 0
mov rdi, 0
mov rsi, key 
mov rdx, 1
syscall

ret

clear_screen:
mov rsi, clear_screen_ASCII_escape
mov rdx, cs_size
call print
ret

set_game_pos_pointer:
mov rsi, game_draw
mov rbx, game_position_pointer

mov rcx, 9

loop_1:
    mov [rbx], rsi
    add rsi, 2

    inc rbx
    loop loop_1

ret

update_draw:
lea rbx, [game_position_pointer + rax]

mov rsi, player

cmp byte[rsi], "0"
je draw_x

cmp byte[rsi], "1"
je draw_o

draw_x:
    mov cl, "x"
    jmp update

draw_o:
    mov cl, "o"
    jmp update

update:

    mov [rbx], cl


ret

check:
call check_line
ret

check_line:

mov rcx, 0

check_line_loop:
    cmp rcx, 0
    je first_line

    cmp rcx, 1
    je second_line

    cmp rcx, 2
    je third_line

    call check_column
    ret

    first_line:
        mov rsi, 0
        jmp do_check_line

    second_line:
        mov rsi, 3
        jmp do_check_line

    third_line:
        mov rsi, 6
        jmp do_check_line

    do_check_line:
        inc rcx

        lea rbx, [game_position_pointer + rsi]
        mov al, [rbx]
        cmp al, "_"
        je check_line_loop

        inc rsi
        lea rbx, [game_position_pointer + rsi]
        cmp al, [rbx]
        jne check_line_loop

        inc rsi
        lea rbx, [game_position_pointer + rsi]
        cmp al, [rbx]
        jne check_line_loop

    mov byte[win_flag], 1
    ret

check_column:
mov rcx, 0

check_colum_loop:
    cmp rcx, 0
    je first_column

    cmp rcx, 1
    je second_column

    cmp rcx, 2
    je third_column

    call check_diagonal
    ret

    first_column:
        mov rsi, 0
        jmp do_check_column

    second_column:
        mov rsi, 1
        jmp do_check_column

    third_column:
        mov rsi, 2
        jmp do_check_column

    do_check_column:
        inc rcx

        lea rbx, [game_position_pointer + rsi]
        mov al, [rbx]
        cmp al, "_"
        je check_colum_loop

        add rsi, 3
        lea rbx, [game_position_pointer + rsi]
        cmp al, [rbx]
        jne check_colum_loop

        add rsi, 3
        lea rbx, [game_position_pointer + rsi]
        cmp al, [rbx]
        jne check_colum_loop

        mov byte[win_flag], 1
        ret

check_diagonal:
mov rcx, 0

check_diagonal_loop:
    cmp rcx, 0
    je first_diagonal

    cmp rcx, 1
    je second_diagonal

    ret

first_diagonal:
    mov rsi, 0
    mov rdx, 4                 ; next jump that will be given to the middle of the diagonal
    jmp do_check_diagonal

second_diagonal:
    mov rsi, 2
    mov rdx, 2
    jmp do_check_diagonal

do_check_diagonal:
    inc rcx

    lea rbx, [game_position_pointer + rsi]
    mov al, [rbx]
    cmp al, "_"
    je check_diagonal_loop

    add rsi, rdx
    lea rbx, [game_position_pointer + rsi]
    cmp al, [rbx]
    jne check_diagonal_loop

    add rsi, rdx
    lea rbx, [game_position_pointer + rsi]
    cmp al, [rbx]
    jne check_diagonal_loop

mov byte[win_flag], 1
ret

game_over:
call clear_screen

mov rsi, game_start_message
mov rdx, gsm_size
call print

mov rsi, new_line
mov rdx, nl_size
call print

mov rsi, game_draw
mov rdx, gd_size
call print

mov rsi, new_line
mov rdx, nl_size
call print

mov rsi, game_over_message
mov rdx, gom_size
call print

mov rsi, player_message
mov rdx, pm_size
call print

mov rsi, player
mov rdx, p_size
call print

mov rsi, win_message
mov rdx, wm_size
call print

jmp fim

fim:
mov rax, 60
mov rdi, 0
syscall
