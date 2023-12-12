import re
import sys

if len(sys.argv) != 2:
    raise RuntimeError("Expected input path argument")

NUMBERS = {
    "one": "1",
    "two": "2",
    "three": "3",
    "four": "4",
    "five": "5",
    "six": "6",
    "seven": "7",
    "eight": "8",
    "nine": "9",
}

res = 0
res2 = 0

with open(sys.argv[1], "r") as file:
    pattern = re.compile(r"\D*(\d(:?.*\d)?)\D*")

    for line in file.readlines():
        if match := pattern.match(line):
            group = match.group(1)
            res += int(group[0]) * 10 + int(group[-1])
        else:
            raise RuntimeError(f"Failed to find digits in line '{line}'")

        for k, v in NUMBERS.items():
            line = line.replace(k, k + v + k)

        if match := pattern.match(line):
            group = match.group(1)
            res2 += int(group[0]) * 10 + int(group[-1])

print(f"Result 1: {res}")
print(f"Result 2: {res2}")
