# Copyright (c) 2021, Nicolás Ruiz Requejo
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
#
# 1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
#
# 2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.


import getopt
import sys
import csv


def main(argv):
    """
        gen_microcode is a tool that makes memory image files

        Providing a csv file with the format:
        1ºrow -> fieldnames
        ith row -> (..., address, data) of memory line
        e.g.:
              | col-0...col-i | col-i+1         | col-i+2...col-N |
        ------+---------------+-----------------+-----------------+
        row-0 | other-field   | memAddressIndex |  bit/bits_group | -> field
        row-1 |               |                 |                 | --  names
         ...  |               |                 |                 |  | --> data
        row-N |               |                 |                 |  |    lines
        ------+---------------+---------------------+-------------+ --
        Generates a file with a number of 2^(memory_address_width) lines
        containing for each row-1 to row-N in csv file in the index give by
        col-i+1, the binary string made up of (col-i+2 to col-N)
        bits/bits_group.
        ====================
        Command line format:
        ====================
        gen_microcode [-h] -l lines -b index input.csv output.dat

        Parameters:
        -h : print help
        -l lines (int): number of input memory address bits
        -b  index (int): index of colum in csv file being an index
                    of memory address
        input (file): .csv filename path with the format specified above
        output (file): .dat filename path with memory image line by line
                    each line represents a sorted address

        Returns:
        file: .dat file with the memory image, e.g.:
            001010
            110101
            101010
            101010
    """
    # ==============================
    # Process command-line arguments
    # ==============================
    shorts = "hl:b:"
    longs = ["help", "lines=", "begin="]
    try:
        opts, filenames = getopt.getopt(argv, shorts, longs)
    except getopt.GetoptError as err:
        print(err)
        sys.exit(1)
    # get remainder options
    for op, val in opts:
        if op in ("-h", "--help"):
            print(help(main))
            sys.exit(0)
        elif op in ("-l", "--lines"):
            memory_lines = 2**int(val)
        elif op in ("-b", "--begin"):
            address_field = int(val)
        else:
            sys.exit("Unknown option " + op + ". Please use -h to get help")
    # check if there are two filenames
    if len(filenames) != 2:
        sys.exit("Please use -h option to get help")
    else:
        input_filename = filenames[0]
        output_filename = filenames[1]
    # check if some variable has not been created
    if (not (('memory_lines' in locals()) and
        ('address_field' in locals()) and
        ('input_filename' in locals()) and
            ('output_filename' in locals()))):
        sys.exit("Missing options. Please use -h to get help")
    # ======================
    # Start proccessing file
    # ======================
    # initialize dict to hold extracted lines from csv
    unordered_data = {}
    # initialice memory image as list (of string lines)
    memory_image = []
    with open(input_filename, newline='') as csvfile, \
            open(output_filename, 'w') as memory_file:
        csvdata = csv.reader(csvfile, dialect='excel')
        # discard first line
        field_names = next(csvdata)
        # Extract second line in order to calculate
        # number of bits of each memory line
        first_memory_line = next(csvdata)
        signals_size = len(''.join(first_memory_line[address_field+1:]))
        unordered_data[
                int(first_memory_line[address_field].strip(), 2)
            ] = first_memory_line[address_field+1:]
        for row in csvdata:
            # memory lines from csv file, not sorted
            unordered_data[
                int(row[address_field].strip(), 2)
            ] = row[address_field+1:]
        # memory_image is a list of sorted memory lines as binary strings
        memory_image = [''.join(['0'] * signals_size) + '\n'] * memory_lines
        # write memory lines extracted from csv file
        for address in unordered_data.keys():
            memory_image[address] = ''.join(unordered_data[address]) + '\n'
        # remove last LF character
        memory_image[memory_lines-1] = memory_image[memory_lines-1].strip()
        # write to memory image file
        memory_file.writelines(memory_image)


if __name__ == "__main__":
    main(sys.argv[1:])
    print("Succesfully written.\n")
