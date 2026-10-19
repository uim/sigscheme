#!/usr/bin/env python3
#
# Runs r7rs-tests.scm of chibi-scheme with SigScheme and reports how
# many tests pass.
#
# SigScheme can't read some R7RS syntax yet. If SigScheme reads
# r7rs-tests.scm directly, it stops at the first unsupported syntax.
# So this splits r7rs-tests.scm into top-level forms and evaluates
# each of them separately. If sscm crashes or hangs, this skips the
# form and continues from the next form.
#
# Usage: run.py [--verbose] SSCM SYSTEM_LOAD_PATH R7RS_TESTS

import argparse
import os
import subprocess
import sys
import tempfile

DELIMITERS = set(' \t\n\r\f()";')


class Splitter:
    def __init__(self, text):
        self.text = text
        self.length = len(text)

    def skip_line_comment(self, i):
        while i < self.length and self.text[i] != '\n':
            i += 1
        return i

    def skip_block_comment(self, i):
        # i points just after '#|'
        depth = 1
        while i < self.length and depth > 0:
            if self.text.startswith('|#', i):
                depth -= 1
                i += 2
            elif self.text.startswith('#|', i):
                depth += 1
                i += 2
            else:
                i += 1
        return i

    def skip_atmosphere(self, i):
        while i < self.length:
            c = self.text[i]
            if c.isspace():
                i += 1
            elif c == ';':
                i = self.skip_line_comment(i)
            elif self.text.startswith('#|', i):
                i = self.skip_block_comment(i + 2)
            elif self.text.startswith('#;', i):
                i = self.skip_datum(i + 2)
            else:
                break
        return i

    def skip_delimited(self, i, close):
        # i points just after the opening character
        while i < self.length:
            c = self.text[i]
            if c == close:
                return i + 1
            if c == '\\':
                i += 2
            else:
                i += 1
        return i

    def skip_list(self, i):
        # i points just after '('
        while True:
            i = self.skip_atmosphere(i)
            if i >= self.length:
                return i
            if self.text[i] == ')':
                return i + 1
            i = self.skip_datum(i)

    def skip_atom(self, i):
        while i < self.length and self.text[i] not in DELIMITERS:
            i += 1
        return i

    def skip_datum(self, i):
        i = self.skip_atmosphere(i)
        if i >= self.length:
            return i
        text = self.text
        c = text[i]
        if c == '(':
            return self.skip_list(i + 1)
        if c == '"':
            return self.skip_delimited(i + 1, '"')
        if c == '|':
            return self.skip_delimited(i + 1, '|')
        if c in "'`":
            return self.skip_datum(i + 1)
        if c == ',':
            if text.startswith(',@', i):
                return self.skip_datum(i + 2)
            return self.skip_datum(i + 1)
        if c == '#':
            if text.startswith('#(', i):
                return self.skip_list(i + 2)
            if text.startswith('#u8(', i):
                return self.skip_list(i + 4)
            if text.startswith('#\\', i):
                # The first character after #\ may be a delimiter.
                return self.skip_atom(i + 3)
            # Datum label such as #0=
            j = i + 1
            while j < self.length and text[j].isdigit():
                j += 1
            if j > i + 1 and j < self.length and text[j] == '=':
                return self.skip_datum(j + 1)
        return self.skip_atom(i)

    def split(self):
        forms = []
        i = 0
        while True:
            i = self.skip_atmosphere(i)
            if i >= self.length:
                return forms
            end = self.skip_datum(i)
            line = self.text.count('\n', 0, i) + 1
            forms.append((line, self.text[i:end]))
            i = end


def scheme_string(text):
    return '"' + text.replace('\\', '\\\\').replace('"', '\\"') + '"'


class Result:
    def __init__(self):
        self.section_stack = []
        self.counts = {}
        # [(kind, section, line, message), ...]
        self.details = []

    def current_section(self):
        if len(self.section_stack) >= 2:
            return self.section_stack[1]
        if self.section_stack:
            return self.section_stack[0]
        return '(top level)'

    def count(self, kind, line=None, message=None):
        section = self.current_section()
        counts = self.counts.setdefault(
            section, {'pass': 0, 'fail': 0, 'form-error': 0})
        counts[kind] += 1
        if message is not None:
            self.details.append((kind, section, line, message))

    def total(self, kind):
        return sum(counts[kind] for counts in self.counts.values())


def run(args, forms, shim, result):
    start = 0
    with tempfile.TemporaryDirectory() as work_dir:
        driver = os.path.join(work_dir, 'driver.scm')
        while start < len(forms):
            with open(driver, 'w', encoding='utf-8') as output:
                output.write(f'(load {scheme_string(shim)})\n')
                for index in range(start, len(forms)):
                    form = forms[index][1]
                    output.write(f'(%r7rs-run-form {index} '
                                 f'{scheme_string(form)})\n')
                output.write('(%r7rs-report "done")\n')
            command = [args.sscm,
                       '--system-load-path', args.system_load_path,
                       driver]
            try:
                process = subprocess.run(command,
                                         cwd=work_dir,
                                         stdout=subprocess.PIPE,
                                         stderr=subprocess.PIPE,
                                         timeout=args.timeout)
                stdout = process.stdout
                stderr = process.stderr
                status = f'exit status {process.returncode}'
            except subprocess.TimeoutExpired as error:
                stdout = error.stdout or b''
                stderr = error.stderr or b''
                status = 'timeout'
            done = False
            last_form = None
            for line in stdout.decode('utf-8', 'replace').splitlines():
                if not line.startswith('@@r7rs '):
                    continue
                kind, _, rest = line[len('@@r7rs '):].partition(' ')
                if kind == 'form':
                    last_form = int(rest)
                elif kind == 'begin':
                    result.section_stack.append(rest)
                elif kind == 'end':
                    if result.section_stack:
                        result.section_stack.pop()
                elif kind == 'pass':
                    result.count('pass')
                elif kind in ('fail', 'form-error'):
                    result.count(kind, forms[last_form][0], rest)
                elif kind == 'done':
                    done = True
            if done:
                break
            if last_form is None:
                sys.stderr.write(f'sscm failed before running tests: '
                                 f'{status}\n')
                sys.stderr.write(stderr.decode('utf-8', 'replace'))
                sys.exit(1)
            result.count('form-error', forms[last_form][0],
                         f'sscm crashed or hung: {status}')
            start = last_form + 1


def report(result, verbose):
    width = max([len(section) for section in result.counts] + [10])
    print(f'{"Section":<{width}}  {"Pass":>5}  {"Fail":>5}  '
          f'{"Form errors":>11}')
    for section, counts in result.counts.items():
        print(f'{section:<{width}}  {counts["pass"]:>5}  '
              f'{counts["fail"]:>5}  {counts["form-error"]:>11}')
    print(f'{"Total":<{width}}  {result.total("pass"):>5}  '
          f'{result.total("fail"):>5}  {result.total("form-error"):>11}')
    print()
    print('Tests in forms that caused form errors are not counted.')
    if verbose:
        print()
        for kind, section, line, message in result.details:
            print(f'{section}: line {line}: {kind}: {message}')


def read_known_failures(path):
    known_failures = {}
    with open(path, encoding='utf-8') as input:
        for line in input:
            line = line.split('#', 1)[0].strip()
            if line:
                number, kind = line.split()
                known_failures[int(number)] = kind
    return known_failures


# Returns whether the failures are the same as KNOWN_FAILURES.
def check_known_failures(result, known_failures):
    failures = {}
    for kind, section, line, message in result.details:
        failures[line] = (kind, message)
    ok = True
    for line, (kind, message) in sorted(failures.items()):
        if known_failures.get(line) not in (kind, 'any'):
            print(f'unexpected {kind}: line {line}: {message}')
            ok = False
    for line, kind in sorted(known_failures.items()):
        if kind != 'any' and line not in failures:
            print(f'fixed: line {line}: remove it from the known failures')
            ok = False
    return ok


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--verbose', action='store_true')
    parser.add_argument('--known-failures',
                        help='fail if the failures differ from this file')
    parser.add_argument('--timeout', type=int, default=10)
    parser.add_argument('sscm')
    parser.add_argument('system_load_path')
    parser.add_argument('r7rs_tests')
    args = parser.parse_args()
    # sscm runs in a temporary directory.
    args.sscm = os.path.abspath(args.sscm)
    args.system_load_path = os.path.abspath(args.system_load_path)

    with open(args.r7rs_tests, encoding='utf-8') as input:
        forms = Splitter(input.read()).split()
    shim = os.path.join(os.path.dirname(os.path.abspath(__file__)),
                        'chibi-test.scm')
    result = Result()
    run(args, forms, shim, result)
    report(result, args.verbose)
    if args.known_failures:
        print()
        if not check_known_failures(result,
                                    read_known_failures(args.known_failures)):
            sys.exit(1)
        print('All failures are known ones.')


if __name__ == '__main__':
    main()
