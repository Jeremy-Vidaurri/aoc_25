from pathlib import Path
import math
import functools

SCRIPT_DIR = Path(__file__).parent
data = None
FINISHED = False

with open(SCRIPT_DIR / "input.txt", 'r') as f:
    data = f.readlines()

trimmed_data = [line.strip('\n') for line in data]

class JunctionBox():
    def __init__(self, coords) -> None:
        self.x, self.y, self.z = coords
        self.connections = set()
        self.circuit_id = -1
    
    def __eq__(self, other):
        return (self.x, self.y, self.z) == (other.x, other.y, other.z)

    def __hash__(self) -> int:
        return hash((self.x, self.y, self.z))

@functools.lru_cache
def get_distance(box_1: JunctionBox, box_2: JunctionBox) -> float:
    x1 = box_1.x
    y1 = box_1.y
    z1 = box_1.z

    x2 = box_2.x
    y2 = box_2.y
    z2 = box_2.z
    return math.sqrt(pow(x2-x1, 2) + pow(y2-y1, 2) + pow(z2-z1, 2))

def connect_closest(points: list[JunctionBox]):
    result = []
    min_dist = float("inf")
    max_idx = -1
    global FINISHED
    FINISHED = True
    for p1 in points:
        for p2 in points:
            if p1 == p2:
                continue
            if p2 in p1.connections:
                continue 
            max_idx = max(p1.circuit_id, p2.circuit_id, max_idx)
            dist = get_distance(p1, p2)
            if dist < min_dist:
                min_dist = dist
                result = [p1, p2]
    
    result[0].connections.add(result[1])
    result[1].connections.add(result[0])
    result[0].connections = result[0].connections.union(result[1].connections)
    result[1].connections = result[1].connections.union(result[0].connections)
    print(f"CONNECTED: {result[0].x} and {result[1].x} = {result[0].x * result[1].x}")

    if result[0].circuit_id == -1 and result[1].circuit_id == -1:
        result[0].circuit_id = max_idx + 1
        result[1].circuit_id = max_idx + 1
    elif result[0].circuit_id == -1 and result[1].circuit_id != -1:
        result[0].circuit_id = result[1].circuit_id
    elif result[0].circuit_id != -1 and result[1].circuit_id == -1:
        result[1].circuit_id = result[0].circuit_id
    else:
        smaller_idx = min(result[0].circuit_id, result[1].circuit_id)
        larger_idx = max(result[0].circuit_id, result[1].circuit_id)
        for point in points:
            if point.circuit_id == larger_idx:
                point.circuit_id = smaller_idx
                result[0].connections = result[0].connections.union(point.connections)
                result[1].connections = result[1].connections.union(point.connections)
                point.connections = point.connections.union(result[0].connections)
                point.connections = point.connections.union(result[1].connections)

points = []

for line in trimmed_data:
    points.append(JunctionBox([int(val) for val in line.split(',')]))

while not all(p.circuit_id == points[0].circuit_id and points[0].circuit_id != -1 for p in points):
    connect_closest(points)

# for i in range(1000):
#     connect_closest(points)

# result = -1

# sizes = {}

# for point in points:
#     if point.circuit_id == -1:
#         continue
#     sizes[point.circuit_id] = sizes.get(point.circuit_id, 0) + 1

# key_list = list(sizes.values())
# key_list.sort()

# result = key_list[-1] * key_list[-2] * key_list[-3]

# print(f"Part 1: {result}")
