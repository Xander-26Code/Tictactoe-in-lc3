.ORIG x3000

; --- Main Program ---

START
    JSR INIT_BOARD      ; Initialize the board with spaces
    JSR CHOOSE_SIDE     ; Let user choose X or O
    ; ST R0, CUR_PLAYER ; CHOOSE_SIDE stores it directly

GAME_LOOP
    JSR PRINT_BOARD     ; Show current board

    ; Check for Win/Draw before asking for move? 
    ; Usually check after move. But let's check if board is full or someone won.
    ; Actually, better to check after a move.

    ; Get Player Move
    JSR GET_MOVE        ; Returns valid move index in R0 (0-8)
    
    ; Update Board
    JSR UPDATE_BOARD    ; Uses R0 (index) and CUR_PLAYER to update board

    ; Check Win
    JSR CHECK_WIN       ; Returns 1 in R0 if win, 0 otherwise
    ADD R0, R0, #0
    BRp GAME_OVER_WIN

    ; Check Draw
    JSR CHECK_DRAW      ; Returns 1 in R0 if draw, 0 otherwise
    ADD R0, R0, #0
    BRp GAME_OVER_DRAW

    ; Switch Player
    LD R0, CUR_PLAYER
    LD R1, CHAR_X
    NOT R1, R1
    ADD R1, R1, #1      ; -'X'
    ADD R2, R0, R1      ; R2 = CUR - 'X'
    BRz SET_O
    LD R0, CHAR_X       ; Was O, set to X
    BRnzp STORE_PLAYER
SET_O
    LD R0, CHAR_O       ; Was X, set to O
STORE_PLAYER
    ST R0, CUR_PLAYER
    BRnzp GAME_LOOP

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

; --- Subroutines ---

; INIT_BOARD: Fills BOARD with spaces
INIT_BOARD
    ST R0, SAVE_R0
    ST R1, SAVE_R1
    ST R7, SAVE_R7
    
    LEA R0, BOARD
    LD R1, CHAR_SPACE
    AND R2, R2, #0
    ADD R2, R2, #9      ; Counter = 9
INIT_LOOP
    STR R1, R0, #0
    ADD R0, R0, #1
    ADD R2, R2, #-1
    BRp INIT_LOOP
    
    LD R0, SAVE_R0
    LD R1, SAVE_R1
    LD R7, SAVE_R7
    RET

; PRINT_BOARD: Prints the 3x3 grid
PRINT_BOARD
    ST R0, SAVE_R0
    ST R1, SAVE_R1
    ST R2, SAVE_R2
    ST R3, SAVE_R3
    ST R7, SAVE_R7

    LEA R0, NEWLINE
    PUTS

    LEA R1, BOARD       ; R1 points to current cell
    AND R2, R2, #0      ; R2 is row counter (0-2)

PRINT_ROW_LOOP
    LEA R0, SPACE_INDENT
    PUTS

    ; Print Cell 1
    LDR R0, R1, #0
    OUT
    LEA R0, V_BAR
    PUTS
    ADD R1, R1, #1

    ; Print Cell 2
    LDR R0, R1, #0
    OUT
    LEA R0, V_BAR
    PUTS
    ADD R1, R1, #1

    ; Print Cell 3
    LDR R0, R1, #0
    OUT
    LEA R0, NEWLINE
    PUTS
    ADD R1, R1, #1

    ; Check if last row
    ADD R2, R2, #1
    ADD R3, R2, #-3
    BRz PRINT_DONE

    ; Print Divider
    LEA R0, H_DIV
    PUTS
    BRnzp PRINT_ROW_LOOP

PRINT_DONE
    LD R0, SAVE_R0
    LD R1, SAVE_R1
    LD R2, SAVE_R2
    LD R3, SAVE_R3
    LD R7, SAVE_R7
    RET

; GET_MOVE: Asks user for move (1-9), validates, returns index 0-8 in R0
GET_MOVE
    ST R1, SAVE_R1
    ST R2, SAVE_R2
    ST R7, SAVE_R7

ASK_AGAIN
    LEA R0, PROMPT_MSG
    PUTS
    LD R0, CUR_PLAYER
    OUT
    LEA R0, COLON
    PUTS

    GETC                ; Read char
    OUT                 ; Echo
    ADD R1, R0, #0      ; Move to R1 for checking

    LEA R0, NEWLINE
    PUTS

    ; Check if '1' <= input <= '9'
    LD R2, ASCII_1_NEG
    ADD R2, R1, R2      ; R2 = Input - '1'
    BRn INVALID_INPUT   ; If < 0, invalid
    ADD R3, R2, #-9     ; Check if > 8 (since 9-1=8)
    BRzp INVALID_INPUT  ; If >= 0 (meaning input > '9'), invalid

    ; Check if spot is empty
    LEA R3, BOARD
    ADD R3, R3, R2      ; R3 = Address of cell
    LDR R3, R3, #0      ; Load content
    LD R4, CHAR_SPACE
    NOT R4, R4
    ADD R4, R4, #1
    ADD R3, R3, R4      ; Content - Space
    BRnp SPOT_TAKEN

    ; Valid
    ADD R0, R2, #0      ; Return index (0-8)
    
    LD R1, SAVE_R1
    LD R2, SAVE_R2
    LD R7, SAVE_R7
    RET

INVALID_INPUT
    LEA R0, INVALID_MSG
    PUTS
    BRnzp ASK_AGAIN

SPOT_TAKEN
    LEA R0, TAKEN_MSG
    PUTS
    BRnzp ASK_AGAIN

; UPDATE_BOARD: Stores CUR_PLAYER at BOARD + R0
UPDATE_BOARD
    ST R1, SAVE_R1
    ST R2, SAVE_R2
    ST R7, SAVE_R7

    LEA R1, BOARD
    ADD R1, R1, R0
    LD R2, CUR_PLAYER
    STR R2, R1, #0

    LD R1, SAVE_R1
    LD R2, SAVE_R2
    LD R7, SAVE_R7
    RET

; CHECK_WIN: Returns 1 in R0 if CUR_PLAYER won, 0 otherwise
CHECK_WIN
    ST R1, SAVE_R1
    ST R2, SAVE_R2
    ST R3, SAVE_R3
    ST R4, SAVE_R4
    ST R7, SAVE_R7

    LD R1, CUR_PLAYER   ; Value to check for
    NOT R1, R1
    ADD R1, R1, #1      ; -PlayerChar

    LEA R2, WINS        ; Pointer to winning combos
    LD R3, WIN_COUNT    ; Number of combos (8)

CHECK_WIN_LOOP
    ; Check first cell of combo
    LDR R4, R2, #0      ; Offset 1
    LEA R0, BOARD
    ADD R0, R0, R4
    LDR R0, R0, #0
    ADD R0, R0, R1      ; Val - Player
    BRnp NEXT_COMBO

    ; Check second cell
    LDR R4, R2, #1      ; Offset 2
    LEA R0, BOARD
    ADD R0, R0, R4
    LDR R0, R0, #0
    ADD R0, R0, R1
    BRnp NEXT_COMBO

    ; Check third cell
    LDR R4, R2, #2      ; Offset 3
    LEA R0, BOARD
    ADD R0, R0, R4
    LDR R0, R0, #0
    ADD R0, R0, R1
    BRnp NEXT_COMBO

    ; WINNER!
    AND R0, R0, #0
    ADD R0, R0, #1
    BRnzp CHECK_WIN_DONE

NEXT_COMBO
    ADD R2, R2, #3      ; Move to next combo (3 offsets per combo)
    ADD R3, R3, #-1
    BRp CHECK_WIN_LOOP

    ; No winner
    AND R0, R0, #0

CHECK_WIN_DONE
    LD R1, SAVE_R1
    LD R2, SAVE_R2
    LD R3, SAVE_R3
    LD R4, SAVE_R4
    LD R7, SAVE_R7
    RET

; CHECK_DRAW: Returns 1 in R0 if board full, 0 otherwise
CHECK_DRAW
    ST R1, SAVE_R1
    ST R2, SAVE_R2
    ST R3, SAVE_R3
    ST R7, SAVE_R7

    LEA R1, BOARD
    LD R2, CHAR_SPACE
    NOT R2, R2
    ADD R2, R2, #1
    AND R3, R3, #0
    ADD R3, R3, #9      ; Check 9 cells

CHECK_DRAW_LOOP
    LDR R0, R1, #0
    ADD R0, R0, R2      ; Cell - Space
    BRz NOT_DRAW        ; If space found, not full
    ADD R1, R1, #1
    ADD R3, R3, #-1
    BRp CHECK_DRAW_LOOP

    ; Full
    AND R0, R0, #0
    ADD R0, R0, #1
    BRnzp CHECK_DRAW_DONE

NOT_DRAW
    AND R0, R0, #0

CHECK_DRAW_DONE
    LD R1, SAVE_R1
    LD R2, SAVE_R2
    LD R3, SAVE_R3
    LD R7, SAVE_R7
    RET


; CHOOSE_SIDE: Asks user to choose 'X' or 'O'
CHOOSE_SIDE
    ST R0, SAVE_R0
    ST R1, SAVE_R1
    ST R7, SAVE_R7

ASK_SIDE
    LEA R0, SIDE_MSG
    PUTS
    GETC
    OUT
    ADD R1, R0, #0      ; Save input to R1
    LEA R0, NEWLINE
    PUTS

    ; Check if 'X'
    LD R0, CHAR_X
    NOT R0, R0
    ADD R0, R0, #1
    ADD R0, R1, R0
    BRz SIDE_VALID

    ; Check if 'x' (lowercase)
    LD R0, CHAR_x_lower
    NOT R0, R0
    ADD R0, R0, #1
    ADD R0, R1, R0
    BRz SET_X_UPPER

    ; Check if 'O'
    LD R0, CHAR_O
    NOT R0, R0
    ADD R0, R0, #1
    ADD R0, R1, R0
    BRz SIDE_VALID

    ; Check if 'o' (lowercase)
    LD R0, CHAR_o_lower
    NOT R0, R0
    ADD R0, R0, #1
    ADD R0, R1, R0
    BRz SET_O_UPPER

    ; Invalid
    LEA R0, INVALID_SIDE
    PUTS
    BRnzp ASK_SIDE

SET_X_UPPER
    LD R1, CHAR_X
    BRnzp SIDE_VALID

SET_O_UPPER
    LD R1, CHAR_O

SIDE_VALID
    ST R1, CUR_PLAYER
    
    LD R0, SAVE_R0
    LD R1, SAVE_R1
    LD R7, SAVE_R7
    RET

; --- Data ---

BOARD       .BLKW 9
CUR_PLAYER  .BLKW 1

CHAR_X      .FILL x0058 ; 'X'
CHAR_O      .FILL x004F ; 'O'
CHAR_x_lower .FILL x0078 ; 'x'
CHAR_o_lower .FILL x006F ; 'o'
CHAR_SPACE  .FILL x0020 ; ' '
ASCII_1_NEG .FILL xFFCF ; -'1' (x31) -> -49 -> xFFCF
COLON       .STRINGZ ": "

NEWLINE     .FILL x000A
            .FILL x0000
SPACE_INDENT .STRINGZ "  "
V_BAR       .STRINGZ " | "
H_DIV       .STRINGZ "  --+---+--\n"

PROMPT_MSG  .STRINGZ "Player "
SIDE_MSG    .STRINGZ "Choose Side (X/O): "
INVALID_SIDE .STRINGZ "Invalid! Enter X or O.\n"
INVALID_MSG .STRINGZ "Invalid input! Enter 1-9.\n"
TAKEN_MSG   .STRINGZ "Spot taken!\n"
WIN_MSG_1   .STRINGZ "Player "
WIN_MSG_2   .STRINGZ " Wins!\n"
DRAW_MSG    .STRINGZ "It's a Draw!\n"

; Winning Combinations (Indices 0-8)
WINS        .FILL #0 .FILL #1 .FILL #2  ; Row 1
            .FILL #3 .FILL #4 .FILL #5  ; Row 2
            .FILL #6 .FILL #7 .FILL #8  ; Row 3
            .FILL #0 .FILL #3 .FILL #6  ; Col 1
            .FILL #1 .FILL #4 .FILL #7  ; Col 2
            .FILL #2 .FILL #5 .FILL #8  ; Col 3
            .FILL #0 .FILL #4 .FILL #8  ; Diag 1
            .FILL #2 .FILL #4 .FILL #6  ; Diag 2
WIN_COUNT   .FILL #8

; Save Registers
SAVE_R0     .BLKW 1
SAVE_R1     .BLKW 1
SAVE_R2     .BLKW 1
SAVE_R3     .BLKW 1
SAVE_R4     .BLKW 1
SAVE_R7     .BLKW 1

.END
