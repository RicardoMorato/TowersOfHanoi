# Python Solution

This is the solution for the Towers of Hanoi problem written in Python.

## Running the solution

If you want to test the solution, enter the folder `/python-version` and run:

```shell
python solution.py
```

This will output the following message in your terminal:

```shell
Hanoi Tower algorithm with 3 disks
Minimum number of movements required is: 7
Move disk 1 from Tower A to Tower C
Move disk 2 from Tower A to Tower B
Move disk 1 from Tower C to Tower B
Move disk 3 from Tower A to Tower C
Move disk 1 from Tower B to Tower A
Move disk 2 from Tower B to Tower C
Move disk 1 from Tower A to Tower C
Algorithm concluded!
```

## Changing the number of disks

If you want to change the number of disks in the algorithm (the default is 3), use the flag `--input-number-of-disks` when running the program, like this:

```shell
python solution.py --input-number-of-disks
```

This time, the output on your terminal will be a bit different:

```terminal
Enter the number of disks for the problem:
```

After adding a number, the algorithm will work as expected, like this:

```terminal
Enter the number of disks for the problem: 4
Hanoi Tower algorithm with 4 disks
Minimum number of movements required is: 15
Move disk 1 from Tower A to Tower B
Move disk 2 from Tower A to Tower C
Move disk 1 from Tower B to Tower C
Move disk 3 from Tower A to Tower B
Move disk 1 from Tower C to Tower A
Move disk 2 from Tower C to Tower B
Move disk 1 from Tower A to Tower B
Move disk 4 from Tower A to Tower C
Move disk 1 from Tower B to Tower C
Move disk 2 from Tower B to Tower A
Move disk 1 from Tower C to Tower A
Move disk 3 from Tower B to Tower C
Move disk 1 from Tower A to Tower B
Move disk 2 from Tower A to Tower C
Move disk 1 from Tower B to Tower C
Algorithm concluded!
```

### Important note on inputting different disk numbers

Please, be careful when adding arbitrary numbers for this algorithm.

Since it has a time complexity of `O(2^N)`, where `N` is the number of disks, depending on your local machine's power, numbers above a certain range (10, 15, 20, etc) may consume more resources than expected, and lead to stuttering.
