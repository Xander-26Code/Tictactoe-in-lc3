.ORIG	x3000

START
    JSR	INIT_BOARD

    CHOOSE_PLAYER

LOOP_GAME

    JSR PRINT_BOARD

    JSR GET_MOVE

    JSR UPDATE_BOARD

    JSR CHECK_WIN
    ADD R0, R0, #0
    BRp GAME_OVER_WIN

    JSR CHECK_DRAW
    ADD R0, R0, #0
    BRp GAME_OVER_DRAW

    ; Switch Player

    AND R1, R1, #0

    ; the R1 will be used to track the current player 
    LD R1, CUR_PLAYER
    
    AND R2, R2, #0
    LD R2, CHAR_X
    NOT R2, R2
    ADD R2, R2, #1 
    ;let R2 = -'X'
    ADD R3, R1, R2
    ; R3 = CUR - 'X'
    BRz SET_O
    LD R1, CHAR_X       ; if BRz SET_O not executes, then was O, set to X

    BRnzp STORE_PLAYER
SET_O
    LD R1, CHAR_O       ; Was X, set to O

STORE_PLAYER
    ST R1, CUR_PLAYER
    BRnzp LOOP_GAME
GAME_OVER_WIN
    JSR PRINT_BOARD     ; Show final board
    LEA R0, WIN_MSG_1
    PUTS
    LD R0, CUR_PLAYER
    OUT
    LEA R0, WIN_MSG_2
    PUTS
    HALT

GAME_OVER_DRAW
    JSR PRINT_BOARD
    LEA R0, DRAW_MSG
    PUTS
    HALT


    ;The data area
    BOARD .FiLL 9 x20  ; 9 spaces for the board
    CUR_PLAYER .FILL x20 ; the current player ('X' or 'O'), but the defalut is space
    CHAR_X .FILL x58    ; ASCII 'X'
    CHAR_O .FILL x4F    ; ASCII 'O'
    VERTICAL_BAR .FILL x7C ; ASCII '|'
    HORIZONTAL_BAR .STRINGZ	" ---|---|---"
    CHAR_SPACE .FILL x20 ; ASCII space
    WIN_MSG_1 .STRINGZ "Player "
    WIN_MSG_2 .STRINGZ " wins! Congratulations!"
    DRAW_MSG .STRINGZ "It's a draw! nb!" 


    ;The subroutines area
PRINT_BOARD
    ST R0, SAVE_R0
    ST R1, SAVE_R1
    ST R2, SAVE_R2
    ST R3, SAVE_R3
    ST R7, SAVE_R7

    AND R3, R3, #0 

    LD R0, NEWLINE
    PUTS ;we print a newline, becauese their may be some words before the board printed.

    LEA R1, BOARD ; lete R1 be the pointer to the board

    AND R2, R2, #0 ;let R2 be the counter for rows

LOOP_PRINT_BOARD
    LDR, R0, R1, #0 ; Load the current cell
    OUT ; Print the cell content
    ADD R1, R1, #1 ; Move the pointer to the next cell

    LD R0, VERTICAL_BAR
    PUTS ; Print the vertical bar

    LDR R0, R1, #0 ; Load the next cell
    OUT ; Print the next cell content
    ADD R1, R1, #1 ; Move the pointer to the next cell

    LD R0, VERTICAL_BAR
    PUTS ; Print the vertical bar
    
.END