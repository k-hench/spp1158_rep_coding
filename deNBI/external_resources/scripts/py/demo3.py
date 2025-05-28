# Python 3 version
import argparse
# parse command line arguments
parser = argparse.ArgumentParser(description="Concatenate sequences from multiple FASTA files")
parser.add_argument('input_number', nargs="+", help="number to devide by 2")
args = parser.parse_args()

# get number from command line argument
num = args.input_number[0]

# Convert to integer
num = int(num)

# Integer division behaves differently; use // for floor division if needed
result = num / 2

# Unicode by default
u_string = "Half of your number is:"

print(u_string, result)
