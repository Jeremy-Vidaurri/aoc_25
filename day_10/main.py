from pathlib import Path
import functools

SCRIPT_DIR = Path(__file__).parent


def backtrack(goal, int_buttons, pos, cur_lights, num_pressed):
    if goal == cur_lights:
        return num_pressed, True
    if pos == len(int_buttons):
        return -1, False
    
    press, press_result = backtrack(goal, int_buttons, pos + 1, cur_lights ^ int_buttons[pos], num_pressed + 1)
    do_not_press, no_press_result = backtrack(goal, int_buttons, pos + 1, cur_lights, num_pressed)

    if press_result and no_press_result:
        return min(press, do_not_press), True
    elif press_result:
        return press, True
    elif no_press_result:
        return do_not_press, True
    else:
        return -1, False
    
def part_one():
    data = None

    with open(SCRIPT_DIR / "input.txt", 'r') as f:
        data = f.readlines()

    trimmed_data = [line.strip() for line in data if len(line) != 0]
    problems = []
    for line in trimmed_data:
        goal, *buttons, _ = line.split()
        
        goal = goal.strip("[]")
        goal = goal.replace('.', '0')
        goal = goal.replace('#', '1')
        goal = goal[::-1]
        int_goal = 0
        for i in range(len(goal)-1, -1, -1):
            pos = len(goal) - 1 - i
            int_goal += pow(2, pos) * int(goal[i])

        int_buttons = []
        for i in range(len(buttons)):
            buttons[i] = buttons[i].strip("()")
            positions = buttons[i].split(",")
            total = 0
            for pos in positions:
                total += pow(2, int(pos))
            
            int_buttons.append(total)

        problems.append([int_goal, int_buttons])
    result = 0
    for problem in problems:
        goal, buttons = problem
        presses, _ = backtrack(goal, buttons, 0, 0, 0)
        result += presses
    print(f"Part 1: {result}")

memo = {}

def hash(joltages):
    result = ""
    for jolt in joltages:
        result += f"{jolt}X"
    return result

def backtrack_two(goal_joltages, cur_joltages, buttons, button_pos, num_presses):
    global memo
    cur_hash = hash(cur_joltages)
    goal_hash = hash(goal_joltages)
    if (cur_hash, goal_hash, num_presses) in memo:
        return memo[(cur_hash, goal_hash, num_presses)]

    if cur_joltages == goal_joltages:
        return num_presses, True
    if button_pos == len(buttons):
        return -1, False
    
    for i in range(len(goal_joltages)):
        goal = goal_joltages[i]
        cur = cur_joltages[i]
        if cur > goal:
            return -1, False

    for val in buttons[button_pos]:
        cur_joltages[val] += 1    
    press, press_result = backtrack_two(goal_joltages, cur_joltages, buttons, button_pos, num_presses + 1)
    for val in buttons[button_pos]:
        cur_joltages[val] -= 1    
    no_press, no_press_result = backtrack_two(goal_joltages, cur_joltages, buttons, button_pos + 1, num_presses)

    if press_result and no_press_result:
        memo[(cur_hash, goal_hash, num_presses)] = (min(press, no_press), True)
    elif press_result:
        memo[(cur_hash, goal_hash, num_presses)] = (press, True)
    elif no_press_result:
        memo[(cur_hash, goal_hash, num_presses)] = (no_press, True)
    else:
        memo[(cur_hash, goal_hash, num_presses)] = (-1, False)
    return memo[(cur_hash, goal_hash, num_presses)]

def part_two():
    global memo
    data = None

    with open(SCRIPT_DIR / "input.txt", 'r') as f:
        data = f.readlines()

    trimmed_data = [line.strip() for line in data if len(line) != 0]
    problems = []
    for line in trimmed_data:
        _, *buttons, joltages = line.split()

        processed_buttons = []
        for i in range(len(buttons)):
            buttons[i] = buttons[i].strip("()")
            positions = buttons[i].split(",")
            positions = [int(pos) for pos in positions]
            processed_buttons.append(positions)
        
        processed_joltages = []
        for jolt in joltages.split(','):
            processed_joltages.append(int(jolt.strip("{}")))
            
        problems.append([processed_buttons, processed_joltages])
    result = 0
    for problem in problems:
        buttons, joltages = problem
        memo = {}
        presses, _ = backtrack_two(joltages, [0 for _ in range(len(joltages))], buttons, 0, 0)
        result += presses
    print(f"Part 1: {result}")

if __name__ == "__main__":
    part_one()
    part_two()