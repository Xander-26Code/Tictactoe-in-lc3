## TicTacToe Game In LC3 Assembly

1. ### The Purpose of the project

Do it just for fun and course homework😎





2. ### The Functionality of the project

Be able to implement the tictactoe game in LC3 assembly language. The tictactoe game is a 3x3 grid where players take turns placing their marks, **X or O** in empty spots. The main goal is to get three of the same marks in a row-horizontally, vertically, or diagonally.





3. ### The User Interface

- Be able to show the game table
- Be able to let the user to choose the sides(whether "X" or "O")

- Be able to output the game board after each player choose their position where the piece placed.
- Be able to ouput the final winner after the game is end.



4. #### The implementation 

- **How to show the game board?**

  We use a `PRINT_BOARD` subroutine to display the grid. It uses a loop to iterate through the memory allocated for the board. For formatting, it prints vertical bars (`|`) between cells and horizontal lines (`---|---|---`) between rows. We use a counter to detect when to print a newline (every 3 cells).

- **How to let the user to choose the sides?**

  We allow the user to decide who goes first. We output a prompt using `PUTS`, accept a single character using `GETC`, echo it to the screen using `OUT`, and store this character in the `CUR_PLAYER` memory location.

- **How to store the information of every small square on the chessboard?**

  We use `.BLKW 9` to allocate a contiguous block of 9 memory words labeled `BOARD`. Each word corresponds to a cell on the grid (indices 0-8) and stores the ASCII code of 'X', 'O', or ' ' (Space).

- **How to switch the player?**

  Since LC-3 lacks high-level `if/else` constructs, we use arithmetic and branching (`BR`). We load the current player's char, subtract 'X'. If the result is zero (meaning it was 'X'), we load 'O' and store it. Otherwise, we load 'X'. This toggles `CUR_PLAYER` between turns.

- **How to update the data in small square?**

  When the user inputs a number (0-8), we calculate the target memory address: `Target_Address = Base_Address_of_BOARD + Offset`. We then use the `STR` instruction to write the current player's symbol into that specific location.

- **How to justify whether the game is over?**

  The game ends if a player wins or if the board is full (Draw). 
  - We use a `MOVES_COUNT` variable to track the total moves. If it reaches 9 with no winner, it's a draw.
  - We call the `CHECK_WIN` subroutine after every move to check for a victory.

- **How to know who win the game?**

  We defined a lookup table `WINS` containing all 8 winning combinations (rows, columns, diagonals). The `CHECK_WIN` subroutine loops through these combinations. For each line, it checks if the 3 corresponding cells in `BOARD` all contain the `CUR_PLAYER`'s symbol. If any line matches, the current player has won.

- **How to output the final winner?**

  If a win is detected, the program branches to `GAME_OVER_WIN`. It uses `LEA` and `PUTS` to print the congratulatory message strings and `LD/OUT` to print the winning player's symbol ('X' or 'O').

- **How to let the game can play many times, not just for once?**

  We use the `INIT_BOARD` subroutine at the `START` of the program. It loops through the `BOARD` memory range and resets every cell to an ASCII Space. It also resets `MOVES_COUNT` to 0. This clears any previous game state.







































