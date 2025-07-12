import 'dart:math';
import 'package:sudoku_app/models/sudoku_board.dart';
import 'package:sudoku_app/models/sudoku_cell.dart';

class SudokuGenerator {
  final Random _random = Random();
  
  // Difficulty settings - number of cells to remove
  static const Map<Difficulty, int> _difficultyCells = {
    Difficulty.easy: 35,    // Remove 35 cells (46 filled)
    Difficulty.medium: 45,  // Remove 45 cells (36 filled)
    Difficulty.hard: 55,    // Remove 55 cells (26 filled)
  };

  Future<SudokuBoard> generatePuzzle(Difficulty difficulty) async {
    // Generate a complete valid sudoku board
    final completeBoard = _generateCompleteBoard();

    // 保存完整解答
    final solution = completeBoard.grid.map((row) =>
      row.map((cell) => cell.value).toList()
    ).toList();

    // Remove cells based on difficulty
    final puzzle = _removeCells(completeBoard, difficulty);

    // 設置解答到謎題中
    puzzle.solution = solution;

    return puzzle;
  }

  SudokuBoard _generateCompleteBoard() {
    final board = SudokuBoard();
    
    // Fill the board using backtracking
    _fillBoard(board.grid);
    
    return board;
  }

  bool _fillBoard(List<List<SudokuCell>> grid) {
    for (int row = 0; row < SudokuBoard.size; row++) {
      for (int col = 0; col < SudokuBoard.size; col++) {
        if (grid[row][col].isEmpty) {
          // Get shuffled numbers 1-9
          final numbers = List.generate(9, (i) => i + 1);
          numbers.shuffle(_random);
          
          for (int num in numbers) {
            if (_isValidPlacement(grid, row, col, num)) {
              grid[row][col].value = num;
              
              if (_fillBoard(grid)) {
                return true;
              }
              
              grid[row][col].value = 0; // Backtrack
            }
          }
          return false;
        }
      }
    }
    return true;
  }

  bool _isValidPlacement(List<List<SudokuCell>> grid, int row, int col, int num) {
    // Check row
    for (int c = 0; c < SudokuBoard.size; c++) {
      if (grid[row][c].value == num) return false;
    }
    
    // Check column
    for (int r = 0; r < SudokuBoard.size; r++) {
      if (grid[r][col].value == num) return false;
    }
    
    // Check 3x3 box
    int boxRow = (row ~/ SudokuBoard.boxSize) * SudokuBoard.boxSize;
    int boxCol = (col ~/ SudokuBoard.boxSize) * SudokuBoard.boxSize;
    
    for (int r = boxRow; r < boxRow + SudokuBoard.boxSize; r++) {
      for (int c = boxCol; c < boxCol + SudokuBoard.boxSize; c++) {
        if (grid[r][c].value == num) return false;
      }
    }
    
    return true;
  }

  SudokuBoard _removeCells(SudokuBoard completeBoard, Difficulty difficulty) {
    final puzzle = completeBoard.copyWith(difficulty: difficulty);
    final cellsToRemove = _difficultyCells[difficulty]!;
    
    // Get all cell positions
    final positions = <List<int>>[];
    for (int row = 0; row < SudokuBoard.size; row++) {
      for (int col = 0; col < SudokuBoard.size; col++) {
        positions.add([row, col]);
      }
    }
    
    // Shuffle positions
    positions.shuffle(_random);
    
    int removed = 0;
    for (final pos in positions) {
      if (removed >= cellsToRemove) break;
      
      final row = pos[0];
      final col = pos[1];
      final originalValue = puzzle.grid[row][col].value;
      
      // Temporarily remove the cell
      puzzle.grid[row][col].value = 0;
      
      // Check if the puzzle still has a unique solution
      if (_hasUniqueSolution(puzzle)) {
        removed++;
      } else {
        // Restore the cell if removing it makes the puzzle invalid
        puzzle.grid[row][col].value = originalValue;
      }
    }
    
    // Mark remaining cells as fixed
    for (int row = 0; row < SudokuBoard.size; row++) {
      for (int col = 0; col < SudokuBoard.size; col++) {
        if (puzzle.grid[row][col].isNotEmpty) {
          puzzle.grid[row][col].isFixed = true;
        }
      }
    }
    
    return puzzle;
  }

  bool _hasUniqueSolution(SudokuBoard board) {
    final solutions = <List<List<int>>>[];
    _findAllSolutions(board.grid, solutions, 2); // Stop after finding 2 solutions
    return solutions.length == 1;
  }

  void _findAllSolutions(
    List<List<SudokuCell>> grid,
    List<List<List<int>>> solutions,
    int maxSolutions,
  ) {
    if (solutions.length >= maxSolutions) return;
    
    // Find first empty cell
    for (int row = 0; row < SudokuBoard.size; row++) {
      for (int col = 0; col < SudokuBoard.size; col++) {
        if (grid[row][col].isEmpty) {
          for (int num = 1; num <= 9; num++) {
            if (_isValidPlacement(grid, row, col, num)) {
              grid[row][col].value = num;
              _findAllSolutions(grid, solutions, maxSolutions);
              grid[row][col].value = 0; // Backtrack
            }
          }
          return;
        }
      }
    }
    
    // If we reach here, we found a complete solution
    final solution = grid.map((row) => 
      row.map((cell) => cell.value).toList()
    ).toList();
    solutions.add(solution);
  }

  SudokuBoard? solvePuzzle(SudokuBoard puzzle) {
    final solution = puzzle.copyWith();
    
    if (_solveBoardBacktrack(solution.grid)) {
      return solution;
    }
    
    return null;
  }

  bool _solveBoardBacktrack(List<List<SudokuCell>> grid) {
    for (int row = 0; row < SudokuBoard.size; row++) {
      for (int col = 0; col < SudokuBoard.size; col++) {
        if (grid[row][col].isEmpty) {
          for (int num = 1; num <= 9; num++) {
            if (_isValidPlacement(grid, row, col, num)) {
              grid[row][col].value = num;
              
              if (_solveBoardBacktrack(grid)) {
                return true;
              }
              
              grid[row][col].value = 0; // Backtrack
            }
          }
          return false;
        }
      }
    }
    return true;
  }

  bool isValidSudoku(SudokuBoard board) {
    for (int row = 0; row < SudokuBoard.size; row++) {
      for (int col = 0; col < SudokuBoard.size; col++) {
        final cell = board.grid[row][col];
        if (cell.isNotEmpty) {
          final value = cell.value;
          cell.value = 0; // Temporarily remove to check validity
          
          if (!_isValidPlacement(board.grid, row, col, value)) {
            cell.value = value; // Restore
            return false;
          }
          
          cell.value = value; // Restore
        }
      }
    }
    return true;
  }
}
