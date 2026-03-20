
[[https://github.com/hugoocoto/flag.h|Github repo]]

Single file flag parser for **C99**. Inspired by python's argparse. 

### Installation:

Choose the most convenient for you:

a. Clone the **repo**, then use `flag.h/flag.h` as you want: 

```sh
git clone https://github.com/hugoocoto/flag.h
```

b. Download just `flag.h` from *main branch, raw*:

```sh
wget https://raw.githubusercontent.com/hugoocoto/flag.h/refs/heads/main/flag.h
```

c. Download from *release*:

```sh
wget https://github.com/hugoocoto/flag.h/releases/download/v1.0/flag.h-1.0.0.zip
unzip flag.h-1.0.0.zip
```

### Quick start / notes:

1. `#include "flag.h"`

2. `flag_program([args])` -- *optional*
     - **args**: zero or more of:  `.name=""`,`.help=""`, `.positionals=flag_list("",""),`
	 
3. `flag_add(char** var, [args])` -- *one per flag*
     - **var**: address of a char pointer that is going to store the flag value
     - **args**: zero or more of: `.opt=""`, `.abbr=""`, `.help=""`, `.nargs=0/1`, `.defaults=""`, `.required=0/1,`

4. `if (flag_parse(&argc, &argv)) { flag_show_help(STDOUT_FILENO); exit(1); }`
5. `flag_free()`

#### Meaning of fields
```c
struct flag_opts {
        const char *opt;  // Flag (--help)
        const char *abbr; // Flag abbreviation (-h)
        char *help;       // Help message for the flag
        int nargs;        // Number of args to catch (max 1)
        char *defaults;   // Default value as string (default is a keyword)
        int required;     // Set to 1 if the flag must be set
        char **var;       // Stores the pointer to the variable where the value should be set
};

static struct program_opts {
        char *name;         // program name. Used in the help message
        char *help;         // program help. Used in the help message
        char **positionals; // possitional arguments (check that argc -1 >= len(it))
} flag_prog = { 0 };


```
#### Important considerations
**argc** and **argv** are modified, the flags and their values are deleted. So the
final **argc** is `1 (program name) + non-flag count`.

For the flag *-f* that expects a parameter, you can use either `-f 1` or `-f=1`.

The values are `(char*)1` or `(char*)0` for boolean flags; and a *heap-allocated*
*copy* of the argument if the flags expect an arg, or `NULL` if not set. The
pointers are set to `0/NULL` by **default**, you don't have to care about this.

This library API uses *optional-like function params*. You have to specify it
as a struct field (`.name=value,`).

You have to increment by hand the number of flags supported, to avoid
reallocations. This is not optimal, I know, but it works fine.


Example:

```c
#include "flag.h"

int
main(int argc, char **argv)
{
        char *b;
        char *foo;

        // Optional. Set program info.
        flag_program(.help = "flag.h by Hugo Coto", .positionals = flag_list("pos1", "pos2"));

        // Register flags. The first argument is a pointer that should be set to
        // the constant string with the argument. If the flag is not set, it
        // would be set to NULL. See flag_opts
        flag_add(&foo, "--foo", "-f", .defaults = "nothing", .help = "foo flag", .nargs = 1);
        flag_add(&b, "--b", .required = 1, .help = "required flag");

        // Check if all the required flags are set. Check if argc is at least
        // the same as the number of positionals. Return 0 if succeed.
        if (flag_parse(&argc, &argv)) {
                // Print help. The flags --help, -h and -help are set by default
                flag_show_help(STDOUT_FILENO);
                exit(1);
        }

        printf("foo = %s\n", foo);

        flag_free();

        return 0;
}
```

#### Output of the previous program with no args

```
./flag
Flag error: Required flag --b not set!
Flag error: Positional argument pos1 not provided!
Flag error: Positional argument pos2 not provided!

usage: ./flag [-h] [-f F] --b pos1 pos2

flag.h by Hugo Coto

options:
 --help, -h     Show this help
 --foo, -f F    foo flag (default: nothing)
 --b    required flag
```


### Copyright / License 

```
Copyright (c) 2026 Hugo Coto Florez

This work is licensed under the Creative Commons Attribution 4.0
International License. To view a copy of this license, visit
http://creativecommons.org/licenses/by/4.0/

SPDX-License-Identifier: CC-BY-4.0
```