import std.stdio, std.conv, std.array, std.typecons;
import std.algorithm;

alias RC = Tuple!(int, "r", int, "c");

void main() {
  int ROWS, COLUMNS; readf("%d %d\n", &ROWS, &COLUMNS);

  int[][] matrix;
  matrix.length = ROWS;
  for(int i=0; i<ROWS; i++)
    matrix[i] = readln.split.to!(int[]);
  debug writeln(matrix);
  
  {
    int[][int] swap_candidates;
    for(int c=0; c<COLUMNS; c++) {
      bool[int] column_in_rows;
      for(int r=0; r<ROWS; r++) {
        int final_row = (matrix[r][c]-1) / COLUMNS;
        if (final_row in column_in_rows) {
          if (r in swap_candidates)
            swap_candidates[r] ~= c;
          else
            swap_candidates[r] = [c];
          continue;
        }
        column_in_rows[final_row] = true;
      }
    }
    foreach(r; swap_candidates.keys) {
      auto cs = swap_candidates[r];
      while(cs.length > 0) {
        int c = cs[0];
        int new_c = (c == 0 ? COLUMNS : c) - 1;
        auto tmp = matrix[r][new_c];
        matrix[r][new_c] = matrix[r][c];
        matrix[r][c] = tmp;
        cs = cs.remove(0);
        cs = cs.remove!(a => a == new_c);
        writeln(cs);
      }
    }
    debug writeln(matrix);
    foreach(r; matrix) r.to!(string[]).join(" ").writeln;
  }
  
  {
    int[][int] swap_candidates;
    for(int c=0; c<COLUMNS; c++) {
      int[] new_column = new int[ROWS];
      for(int r=0; r<ROWS; r++) {
        int final_row = (matrix[r][c]-1) / COLUMNS;
        new_column[final_row] = matrix[r][c];
      }
      for(int r=0; r<ROWS; r++) {
        matrix[r][c] = new_column[r];
      }
    }
    debug writeln(matrix);
    foreach(r; matrix) r.to!(string[]).join(" ").writeln;
  }
}
