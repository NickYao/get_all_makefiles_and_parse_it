#!/usr/bin/env python3
import os
import sys
import argparse

def parse_makefile(makefile, key_words):
    result = []
    lines = None 
    with open(makefile, 'r') as m:
        lines = m.readlines()
        for index in range(len(lines)):
            line = lines[index].rstrip()
            for k in key_words:
                if line.startswith(k):
                    result.append(line)
                    print(line, "first", index)
                    while line.endswith('\\'):
                        index += 1
                        line = lines[index].rstrip()
                        print(line, 'never stop', index)
                        result.append(line)
                    break
    return result


def read_file_line_by_line(filename):
    contents = []
    with open(filename, 'r') as f:
        lines = f.readlines()
        for line in lines:
            contents.append(line.rstrip())
    return contents


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--makefiles", required=True)
    parser.add_argument("--bp-templates", required=True)
    parser.add_argument("--mk-templates", required=True)
    args = parser.parse_args()

    makefiles = read_file_line_by_line(args.makefiles) 
    bp_patterns = read_file_line_by_line(args.bp_templates) 
    mk_patterns = read_file_line_by_line(args.mk_templates) 
    for makefile in makefiles:
        ext = os.path.splitext(makefile)
        key_words = []
        if ext[1] == '.bp':
            key_words = bp_patterns
        if ext[1] == '.mk':
            key_words = mk_patterns
        parsed_data = parse_makefile(makefile, key_words)
        with open(makefile+'.json', 'w') as j:
            j.write('\n'.join(parsed_data))

if __name__ == '__main__':
    sys.exit(main())
