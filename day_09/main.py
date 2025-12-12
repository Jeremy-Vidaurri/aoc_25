from pathlib import Path

SCRIPT_DIR = Path(__file__).parent
data = None

with open(SCRIPT_DIR / "input.txt", 'r') as f:
    data = f.readlines()

trimmed_data = [line.strip('\n') for line in data]
points = [[int(coord) for coord in line.split(',')] for line in trimmed_data]

def calc_area(point_1, point_2):
    x1, y1 = point_1
    x2, y2 = point_2

    length = abs(x2-x1 + 1)
    width = abs(y2-y1 + 1)
    return length * width

result = 0
for p1 in points:
    for p2 in points:
        result = max(result, calc_area(p1,p2))

print(f"Part 1: {result}")