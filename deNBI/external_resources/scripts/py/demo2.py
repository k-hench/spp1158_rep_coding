# Python 2 version
import argparse
# parse command line arguments
parser = argparse.ArgumentParser(description="Concatenate sequences from multiple FASTA files")
parser.add_argument('input_number', nargs="+", help="number to devide by 2")
args = parser.parse_args()

# get number from command line argument
num = args.input_number[0]

# Explicitly convert to integer
num = int(num)

# Integer division
result = num / 2

# Unicode string (optional example)
u_string = u"Half of your number is:"

print u_string, result