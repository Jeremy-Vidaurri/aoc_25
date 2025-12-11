from pathlib import Path
import functools

SCRIPT_DIR = Path(__file__).parent
data = None


with open(SCRIPT_DIR / "input.txt", 'r') as f:
    data = f.readlines()

trimmed_data = [line.strip('\n') for line in data]

grid = []

for line in trimmed_data:
    row = []
    for char in line:
        row.append(char)
    grid.append(row)


s_pos = [-1,-1]
for i in range(len(grid[0])):
    if grid[0][i] == 'S':
        s_pos = [0, i]
        break

queue = [s_pos]
result = set()

while len(queue) != 0:
    row, col = queue.pop(0)
    
    if row == len(grid) - 1 or (row, col) in result:
        continue

    if grid[row + 1][col] == ".":
        queue.append([row+1, col])
        continue

    # if we're here, we hit a ^
    result.add((row, col))
    if col != 0:
        queue.append([row+1, col - 1])
    if col != len(grid[0]) - 1:
        queue.append([row+1, col+1])

print(f"Part 1: {len(result)}")

@functools.lru_cache
def track(row, col):
    if row == len(grid) - 1:
        return 1
    
    if grid[row + 1][col] == ".":
        return track(row+1, col)

    left = 0
    right = 0
    if col != 0:
        left = track(row+1, col - 1)
    if col != len(grid[0]) - 1:
        right = track(row+1, col+1)
    
    return left + right

row, col = s_pos
result = track(row, col)
print(f"Part 2: {result}")
