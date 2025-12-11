from pathlib import Path

SCRIPT_DIR = Path(__file__).parent
data = None


with open(SCRIPT_DIR / "src" / "input.txt", 'r') as f:
    data = f.readlines()

trimmed_data = [line.strip('\n') for line in data]

grid = []

for line in trimmed_data:
    row = []
    for char in line:
        row.append(char)
    grid.append(row)

cur_op = ""
result = 0
cur_total = 0
for col in range(len(grid[0])):
    if grid[-1][col] == "*":
        cur_total = 1
        cur_op = '*'
    elif grid[-1][col] == "+":
        cur_total = 0
        cur_op = '+'
    elif grid[0][col] == " " and grid[1][col] == " " and grid[2][col] == " "and grid[3][col] == " ":
        result += cur_total
        continue

    value = 0
    num_places = 3
    thousands = int(grid[0][col]) if grid[0][col].isnumeric() else -1
    hundreds = int(grid[1][col]) if grid[1][col].isnumeric() else -1
    tens = int(grid[2][col]) if grid[2][col].isnumeric() else -1
    ones = int(grid[3][col]) if grid[3][col].isnumeric() else -1

    value = [thousands, hundreds, tens, ones]
    value = [str(place) for place in value if place != -1]
    value = "".join(value)
    value = int(value)

    if cur_op == "*":
        cur_total *= value
    else:
        cur_total += value

result += cur_total

print(result)
