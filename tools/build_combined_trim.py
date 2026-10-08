#!/usr/bin/env python3
#
# Generates sigscheme-combined-trim.h that undefines internal macros
# defined in SigScheme sources. sigscheme-combined.c includes it at the
# end to avoid leaking the macros into a package that includes
# sigscheme-combined.c.
#
# Usage: build_combined_trim.py OUTPUT SOURCE_DIR SOURCE...

import os
import re
import sys

DEFINE_PATTERN = re.compile(rb'^\s*#define\s+(\w+)')
INCLUDE_GUARD_PATTERN = re.compile(rb'^__\w+_H$')


def main():
    output, source_dir, *sources = sys.argv[1:]
    with open(output, 'wb') as output_file:
        output_file.write(
            b"/* This is an auto-generated file. Don't edit directly. */\n")
        for source in sources:
            output_file.write(b'\n')
            output_file.write(f'/* {source} */\n'.encode())
            undefined_macros = set()
            with open(os.path.join(source_dir, source), 'rb') as source_file:
                for line in source_file:
                    match = DEFINE_PATTERN.match(line)
                    if not match:
                        continue
                    macro = match.group(1)
                    if (macro not in undefined_macros and
                            not INCLUDE_GUARD_PATTERN.match(macro)):
                        output_file.write(b'#undef ' + macro + b'\n')
                    undefined_macros.add(macro)


if __name__ == '__main__':
    main()
