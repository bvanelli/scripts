import numpy as np
from typing import List


def is_valid(sudoku: np.array, x: int, y: int, value: int) -> bool:
    return value not in sudoku[x, :] and value not in sudoku[:, y] and value not in quadrant(sudoku, x, y)


def quadrant(sudoku: np.array, x: int, y: int) -> np.array:
    xx = x // 3
    yy = y // 3
    return sudoku[xx * 3 : (xx + 1) * 3, yy * 3 : (yy + 1) * 3]


def possibilities(sudoku: np.array, x: int, y: int) -> List[int]:
    _possibilities = []
    for value in range(1, 10):
        if is_valid(sudoku, x, y, value):
            _possibilities.append(value)
    return _possibilities


def solver(sudoku: np.array) -> List[np.array]:
    solutions = []
    for (x, y), value in np.ndenumerate(sudoku):
        if value == 0:
            for possibility in possibilities(sudoku, x, y):
                sudoku[x, y] = possibility
                extra_solutions = solver(sudoku)
                solutions.extend(extra_solutions)
                sudoku[x, y] = 0
            return solutions
    solutions.append(sudoku.copy())
    return solutions


if __name__ == '__main__':
    my_sudoku = np.array([5, 3, 0, 0, 7, 0, 0, 0, 0,
                          6, 0, 0, 1, 9, 5, 0, 0, 0,
                          0, 9, 8, 0, 0, 0, 0, 6, 0,
                          8, 0, 0, 0, 0, 0, 0, 0, 3,
                          4, 0, 0, 8, 0, 3, 0, 0, 1,
                          7, 0, 0, 0, 2, 0, 0, 0, 6,
                          0, 6, 0, 0, 0, 0, 2, 8, 0,
                          0, 0, 0, 4, 1, 9, 0, 0, 5,
                          0, 0, 0, 0, 8, 0, 0, 7, 9]).reshape([9, 9])
    my_solutions = solver(my_sudoku)
    for solution in my_solutions:
        print(solution)
