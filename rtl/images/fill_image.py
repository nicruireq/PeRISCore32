###################################
#
#   fill_image.py
#
#   Nicolas Ruiz Requejo(C)
#
###################################

import sys
import getopt


def main():
    n = 0
    input_file = ""
    lines_to_append = 0
    max_line_width = 0
    previous_lines = []

    argument_list = sys.argv[1:]
    options = "hn:"
    long_options = ["help", "rows="]
    try:
        optlist, args = getopt.getopt(argument_list, options, long_options)
    except getopt.GetoptError as err:
        print(err)
        usage(2)
    for o, a in optlist:
        if o in ("-h", "--help"):
            usage(0)
            sys.exit()
        elif o in ("-n", "--rows"):
            n = int(a)
        else:
            sys.exit("Unknown option. Type -h or --help.")
    if len(args) != 1:
        sys.exit("Missing input filename. Type -h or --help.")
    else:
        input_file = args[0]

    # check for input validity
    with open(input_file, "rt") as image_file:
        lines = 0
        for line in image_file:
            if not line.isspace():
                # count not empty lines
                lines = lines + 1
                # get length of largest one
                max_line_width = max_line_width if max_line_width > (len(line)-1) else (len(line)-1)
                # save the line
                previous_lines.append(line)
        if lines <= 0:
            sys.exit("File is empty")
        else:
            lines_to_append = n - lines
        if lines_to_append <= 0:
            sys.exit("There is not enough lines to write")

    with open(input_file, "wt") as image_file:
        # convert list of read lines to string
        text_previous_lines = "".join(previous_lines)
        # adds new line character to previous lines if needed
        if not text_previous_lines.endswith("\n"):
            text_previous_lines = text_previous_lines + "\n"
        # rewrite file content
        image_file.write(text_previous_lines)
        # generate line of zeros
        symbol = "".join(["0" for x in range(max_line_width)])
        # generate string of zero lines and write to file
        new_lines = "\n".join([symbol for x in range(lines_to_append)])
        image_file.write(new_lines)


def usage(num_code):
    print("Syntax: fill_image [-h|--help]" +
          "-n|--rows number_of_rows_in_file filename")
    sys.exit(num_code)


if __name__ == "__main__":
    main()
