from z3 import *

input = """[.##.] (3) (1,3) (2) (2,3) (0,2) (0,1) {3,5,4,7}
[...#.] (0,2,3,4) (2,3) (0,4) (0,1,2) (1,2,3,4) {7,5,12,7,2}
[.###.#] (0,1,2,3,4) (0,3,4) (0,1,2,4,5) (1,2) {10,11,11,5,10,5}"""

with open("input/2025/10.txt", "r") as file:
    input = file.read()

result = 0
for line in input.splitlines():
    _, *buttons, joltages = line.split()

    buttons = [list(map(int, button[1:-1].split(","))) for button in buttons]
    joltages = list(map(int, joltages[1:-1].split(",")))

    xs = []
    for i in range(len(buttons)):
        xs.append(Int(f"x{i}"))

    solver = Optimize()

    for x in xs:
        solver.add(x >= 0)

    matrix = [[0 for _ in range(len(buttons))] for _ in range(len(joltages))]
    for j, button in enumerate(buttons):
        for i in button:
            matrix[i][j] = 1

    for i, joltage in enumerate(joltages):
        solver.add(sum([x for j, x in enumerate(xs) if matrix[i][j] == 1]) == joltages[i])

    solver.minimize(sum(xs))

    if solver.check() == sat:
        model = solver.model()

        result += sum(model[x].as_long() for x in xs)
    else:
        print("No solution found!")

print(result)
