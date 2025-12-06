.ORIG	x3000

; --- Main Program ---

START
    JSR	INIT_BOARD
    
    ; Initialize move counter
    AND R0, R0, #0
    ST R0, MOVES_COUNT

    JSR CHOOSE_PLAYER

LOOP_GAME

    JSR PRINT_BOARD
    JSR GET_MOVE
    JSR UPDATE_BOARD

    ; Increment move counter
    LD R0, MOVES_COUNT
    ADD R0, R0, #1
    ST R0, MOVES_COUNT

    JSR CHECK_WIN
    ADD R0, R0, #0
    BRp GAME_OVER_WIN

    ; Check for Draw (Moves == 9)
    LD R0, MOVES_COUNT
    ADD R0, R0, #-9
    BRz GAME_OVER_DRAW

    ; Switch Player
    AND R1, R1, #0
    LD R1, CUR_PLAYER
    
    AND R2, R2, #0
    LD R2, CHAR_X_GLOB
    NOT R2, R2
    ADD R2, R2, #1 
    ADD R3, R1, R2
    BRz SET_O
    LD R1, CHAR_X_GLOB
    BRnzp STORE_PLAYER
SET_O
    LD R1, CHAR_O_GLOB

STORE_PLAYER
    ST R1, CUR_PLAYER
    BRnzp LOOP_GAME

GAME_OVER_WIN
    JSR PRINT_BOARD
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

; --- Global Data Block ---

MOVES_COUNT .FILL #0
BOARD       .BLKW 9
CUR_PLAYER  .FILL x20

CHAR_X_GLOB .FILL x58    ; 'X'
CHAR_O_GLOB .FILL x4F    ; 'O'
CHAR_SPACE  .FILL x20    ; ' '

WIN_MSG_1   .STRINGZ "\nPlayer "
WIN_MSG_2   .STRINGZ " wins! Congratulations!\n"
DRAW_MSG    .STRINGZ "\nIt's a draw! nb!\n" 

; --- Subroutines ---

PRINT_BOARD
    ST R0, PB_SAVE_R0
    ST R1, PB_SAVE_R1
    ST R2, PB_SAVE_R2
    ST R3, PB_SAVE_R3
    ST R7, PB_SAVE_R7

    AND R3, R3, #0 

    LD R0, PB_NEWLINE
    OUT  

    LD R1, PB_PTR_BOARD ; R1 will the pointer to the BOARD
    AND R2, R2, #0 

LOOP_PRINT_BOARD
    ; [UI FIX] trhe format will be like: " Cell " (Space, Cell, Space)
    LD R0, CHAR_SPACE
    OUT ; Pre-padding
    
    LDR R0, R1, #0 
    OUT ; Cell Content
    
    LD R0, CHAR_SPACE
    OUT ; Post-padding
    
    ADD R1, R1, #1 

    LD R0, PB_V_BAR
    OUT  

    ; Cell 2
    LD R0, CHAR_SPACE
    OUT 
    LDR R0, R1, #0 
    OUT 
    LD R0, CHAR_SPACE
    OUT 
    ADD R1, R1, #1 

    LD R0, PB_V_BAR
    OUT  
    
    ; Cell 3
    LD R0, CHAR_SPACE
    OUT
    LDR R0, R1, #0 
    OUT
    LD R0, CHAR_SPACE
    OUT
    ADD R1, R1, #1

    LD R0, PB_NEWLINE
    OUT 

    ADD R2, R2, #1
    ADD R4, R2, #-3
    BRz END_PRINT_BOARD
    
    LEA R0, PB_H_BAR ; "---|---|---"
    PUTS 
    BRnzp LOOP_PRINT_BOARD

END_PRINT_BOARD
    LD R0, PB_SAVE_R0
    LD R1, PB_SAVE_R1
    LD R2, PB_SAVE_R2
    LD R3, PB_SAVE_R3
    LD R7, PB_SAVE_R7
    RET

; Local constants for PRINT_BOARD
PB_PTR_BOARD .FILL BOARD
PB_NEWLINE .FILL x0A
PB_V_BAR   .FILL x7C
PB_H_BAR   .STRINGZ "---|---|---\n" ; [UI FIX] Aligned with 3-char cells
PB_SAVE_R0 .BLKW 1
PB_SAVE_R1 .BLKW 1
PB_SAVE_R2 .BLKW 1
PB_SAVE_R3 .BLKW 1
PB_SAVE_R7 .BLKW 1


INIT_BOARD
    ST R0, IB_SAVE_R0
    ST R1, IB_SAVE_R1
    ST R7, IB_SAVE_R7

    LD R1, IB_PTR_BOARD
    AND R0, R0, #0
    LD R2, CHAR_SPACE 
    ADD R3, R0, #9    
INIT_LOOP
    STR R2, R1, #0
    ADD R1, R1, #1 
    ADD R3, R3, #-1 
    BRp INIT_LOOP
    LD R0, IB_SAVE_R0
    LD R1, IB_SAVE_R1
    LD R7, IB_SAVE_R7
    RET

IB_PTR_BOARD .FILL BOARD
IB_SAVE_R0 .BLKW 1
IB_SAVE_R1 .BLKW 1
IB_SAVE_R7 .BLKW 1


CHOOSE_PLAYER
    ST R0, CP_SAVE_R0
    ST R1, CP_SAVE_R1
    ST R7, CP_SAVE_R7
    LEA R0, CP_MSG
    PUTS

    GETC
    OUT
    LD R1, CP_PTR_CUR_PLAYER
    STR R0, R1, #0 
    
    LD R0, CP_SAVE_R0
    LD R1, CP_SAVE_R1
    LD R7, CP_SAVE_R7
    RET

CP_PTR_CUR_PLAYER .FILL CUR_PLAYER
CP_MSG .STRINGZ "Choose your player (X/O): "
CP_SAVE_R0 .BLKW 1
CP_SAVE_R1 .BLKW 1
CP_SAVE_R7 .BLKW 1


GET_MOVE
    ST R0, GM_SAVE_R0
    ST R1, GM_SAVE_R1
    ST R7, GM_SAVE_R7
    ST R3, GM_SAVE_R3
    ST R4, GM_SAVE_R4
    ST R5, GM_SAVE_R5

    ; [UI FIX] Show "Player X, enter..."
    LEA R0, GM_MSG_TURN
    PUTS
    
    LD R1, GM_PTR_CUR_PLAYER
    LDR R0, R1, #0
    OUT
    
    LEA R0, GM_PROMPT
    PUTS

GET_MOVE_LOOP
    GETC
    ; Check validity: '0' <= Input <= '8'
    LD R4, GM_ASCII_0
    NOT R4, R4
    ADD R4, R4, #1  ; R4 = -'0'
    
    ADD R5, R0, R4  ; R5 = Input - '0'
    BRn GET_MOVE_LOOP ; If negative (e.g., newline), ignore and retry
    
    ADD R4, R5, #-8
    BRp GET_MOVE_LOOP ; If > 8, ignore and retry

    ; Valid input
    OUT             ; Echo valid input

    ADD R3, R5, #0  ; Return Integer value (0-8) in R3
    
    LD R0, GM_NEWLINE
    OUT

    LD R0, GM_SAVE_R0
    LD R1, GM_SAVE_R1
    LD R7, GM_SAVE_R7
    LD R4, GM_SAVE_R4
    LD R5, GM_SAVE_R5
    ; R3 is return value
    RET

GM_PTR_CUR_PLAYER .FILL CUR_PLAYER
GM_MSG_TURN .STRINGZ "Player "
GM_PROMPT   .STRINGZ ", enter your move (0-8): "
GM_ASCII_0  .FILL x30
GM_NEWLINE  .FILL x0A

GM_SAVE_R0 .BLKW 1
GM_SAVE_R1 .BLKW 1
GM_SAVE_R7 .BLKW 1
GM_SAVE_R3 .BLKW 1
GM_SAVE_R4 .BLKW 1
GM_SAVE_R5 .BLKW 1


UPDATE_BOARD
    ST R0, UB_SAVE_R0
    ST R1, UB_SAVE_R1
    ST R7, UB_SAVE_R7
    ST R2, UB_SAVE_R2
    
    LD R1, UB_PTR_BOARD 
    ADD R1, R1, R3 
    
    LDR R2, R1, #0 
    
    LD R2, UB_PTR_CUR_PLAYER
    LDR R0, R2, #0 
    
    STR R0, R1, #0 
    
    LD R0, UB_SAVE_R0
    LD R1, UB_SAVE_R1
    LD R2, UB_SAVE_R2
    LD R7, UB_SAVE_R7
    RET

UB_PTR_BOARD .FILL BOARD
UB_PTR_CUR_PLAYER .FILL CUR_PLAYER
UB_SAVE_R0 .BLKW 1
UB_SAVE_R1 .BLKW 1
UB_SAVE_R2 .BLKW 1
UB_SAVE_R7 .BLKW 1


CHECK_WIN
    ST R0, CW_SAVE_R0
    ST R1, CW_SAVE_R1
    ST R2, CW_SAVE_R2
    ST R3, CW_SAVE_R3
    ST R4, CW_SAVE_R4
    ST R5, CW_SAVE_R5
    ST R6, CW_SAVE_R6
    ST R7, CW_SAVE_R7

    LD R1, CW_PTR_BOARD
    LD R2, CW_PTR_CUR_PLAYER
    LDR R2, R2, #0
    
    NOT R2, R2
    ADD R2, R2, #1 
    
    LEA R4, WINS      
    AND R5, R5, #0
    ADD R5, R5, #8    

CHECK_WIN_LOOP
    LDR R6, R4, #0    
    LD R1, CW_PTR_BOARD
    ADD R1, R1, R6    
    LDR R3, R1, #0    
    ADD R3, R3, R2   
    BRnp CHECK_NEXT_COMBO

    LDR R6, R4, #1    
    LD R1, CW_PTR_BOARD
    ADD R1, R1, R6
    LDR R3, R1, #0
    ADD R3, R3, R2
    BRnp CHECK_NEXT_COMBO

    LDR R6, R4, #2    
    LD R1, CW_PTR_BOARD
    ADD R1, R1, R6
    LDR R3, R1, #0
    ADD R3, R3, R2
    BRnp CHECK_NEXT_COMBO
    
    AND R0, R0, #0
    ADD R0, R0, #1
    BRnzp END_CHECK_WIN

CHECK_NEXT_COMBO
    ADD R4, R4, #3    
    ADD R5, R5, #-1   
    BRp CHECK_WIN_LOOP
    
    AND R0, R0, #0    

END_CHECK_WIN
    LD R1, CW_SAVE_R1
    LD R2, CW_SAVE_R2
    LD R3, CW_SAVE_R3
    LD R4, CW_SAVE_R4
    LD R5, CW_SAVE_R5
    LD R6, CW_SAVE_R6
    LD R7, CW_SAVE_R7
    RET

CW_PTR_BOARD      .FILL BOARD
CW_PTR_CUR_PLAYER .FILL CUR_PLAYER

CW_SAVE_R0 .BLKW 1
CW_SAVE_R1 .BLKW 1
CW_SAVE_R2 .BLKW 1
CW_SAVE_R3 .BLKW 1
CW_SAVE_R4 .BLKW 1
CW_SAVE_R5 .BLKW 1
CW_SAVE_R6 .BLKW 1
CW_SAVE_R7 .BLKW 1

WINS    .FILL #0 
        .FILL #1 
        .FILL #2  
        .FILL #3 
        .FILL #4 
        .FILL #5  
        .FILL #6 
        .FILL #7 
        .FILL #8  
        .FILL #0 
        .FILL #3 
        .FILL #6  
        .FILL #1 
        .FILL #4 
        .FILL #7  
        .FILL #2 
        .FILL #5 
        .FILL #8  
        .FILL #0 
        .FILL #4 
        .FILL #8  
        .FILL #2 
        .FILL #4 
        .FILL #6  

.END