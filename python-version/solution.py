import sys
import argparse


def calculate_minimum_number_of_moves(number_of_disks: int) -> int:
    if number_of_disks < 0:
        return 0

    return pow(2, number_of_disks) - 1


def tower_of_hanoi_solution(
    disk_number: int, source: str, destination: str, auxiliar: str
) -> None:
    if disk_number <= 0:
        return

    tower_of_hanoi_solution(disk_number - 1, source, auxiliar, destination)
    print("Move disk", disk_number, "from", source, "to", destination)
    tower_of_hanoi_solution(disk_number - 1, auxiliar, destination, source)


if __name__ == "__main__":
    parser = argparse.ArgumentParser("solution")
    parser.add_argument(
        "--input-number-of-disks",
        action="store_true",
        help="Use this flag if you want to manually input the number of disks",
    )

    args = parser.parse_args()

    should_read_user_input = getattr(args, "input_number_of_disks", False)

    NUMBER_OF_DISKS = 3

    if should_read_user_input:
        NUMBER_OF_DISKS = int(input("Enter the number of disks for the problem: "))

    min_number_of_moves = calculate_minimum_number_of_moves(
        number_of_disks=NUMBER_OF_DISKS
    )

    print(f"Hanoi Tower algorithm with {NUMBER_OF_DISKS} disks")
    print(f"Minimum number of movements required is: {min_number_of_moves}")

    tower_of_hanoi_solution(
        NUMBER_OF_DISKS, source="Tower A", destination="Tower C", auxiliar="Tower B"
    )

    print("Algorithm concluded!")
