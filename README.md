# advent-of-code-2024-nasm
Advent of code 2024 written in NASM assembly.

Solutions to each day stored in Dayxx/day_xx.asm

Any general purpose function created along the way (print functions, creating an int array from a char buffer, casting a char buffer to an int, etc) are stored in utils.asm and imported by the daily challenge solution.

Code can be compiled and run using the command below, substituting "day_01" for the relevant day. This should be called from inside the folder for that day's challenge.

"nasm -felf64 day_01.asm && ld day_01.o && ./a.out && rm day_01.o && rm a.out"
