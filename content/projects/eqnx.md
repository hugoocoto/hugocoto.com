---
tags:
  - projects
  - C
  - ESX
  - guides
---
Eqnx (equinox) is a library for composing applications by merging independent
plugins. It's single thread, event-based and easy to use.

- [[#Quickstart]]
- [[#Architecture]]
- [[#Eqnx API]]
- [[#ESX API]]
- [[#Language agnosticism]]

> This tool provides the structural foundation for various software extensions to
> seamlessly  coexist within a single visual space. Users can program autonomous
> components that not only display information on a character matrix but also act
> as orchestrators for other subcomponents. This visual hierarchy grants
> developers absolute control over the interface layout and interaction
> distribution, ensuring that every element operates in a fluid and coordinated
> manner.


## Quickstart

The first thing that you need is an executable copy of `eqnx`. You can compile
it by hand or get a compiled version. Then, you need a [[#ESX Program
Descriptions]], eqnx is distributed with more than one. Once you have both the
executable and the program description, you can execute it from the command
line: `eqnx -p ./program.esx`, where `./program.esx` is the path to the **esx**
file. 

### Event Callbacks

You can define callback handlers as functions, just by declaring and defining
them in the plugin source code. The following signatures can be used:

- `int (*kp_event)(int sym, int mods);`: [[#kp_event]]
- `int (*main)(int, char **);`: [[#main]]
- `int (*pointer_event)(Pointer_Event);`: [[#pointer_event]]
- `int (*render)();`: [[#render]]
- `int (*resize)(int x, int y, int w, int h);`: [[#resize]]

They are called if events of the given type are caught by its parent and
explicitly sent to the plugin. A plugin don't have to implement all of them,
just those what they want to catch.
#### resize

This function is called when window is resized. Top left corner is on `(x,y)`
pixels, with `w` and `h` pixels width and height. Use window_px_to_coords() to
get the window size in chars, as in the following code.
```c
void
resize(int x, int y, int w, int h)
{
        // (How to) get size in chars
        int cx, cy, cw, ch;
        window_px_to_coords(x, y, &cx, &cy);
        window_px_to_coords(w, h, &cw, &ch);
}
```

#### kp_event

Key press event. A key has been pressed
```c
void
kp_event(int sym, int mods)
{
}
```

#### pointer_event

Pointer event. A mouse event (movement, click, scroll) has happened.
```c
void
pointer_event(Pointer_Event e)
{
}
```

#### render

This function is called when the program request a new frame. You can request
a new frame from other functions using ask_for_redraw().
```c
void
render()
{
        // Draw stuff in the window here
}
```

#### main

Main function - entry point.
```c
int
main(int argc, char **argv)
{
        /* Your initializations here */
        mainloop(); // Start receiving events. This is a blocking function.
        /* Your deinitializations here */
        return 0;
}
```


### Magic Global Variables

There are a few global variables that if **declared** they get assigned
automatically on plugin loading. The following variables should not be used if
they're not needed. It's recommended to use API calls instead.
- `Window* self_window`: It gets a reference to the window that is associated with the plugin.
- `Plugin* self_plugin`: It gets a reference to the Plugin structure of the plugin.

## ESX Program Descriptions

**Eqnx S-eXpressions** (*esx*) is the pseudo-language used to describe Eqnx
Programs. It describes the plugin composition in a deterministic, recursive way.

### Structure 

- **Atom**: `atom`, plugin name. Of the form `[_a-zA-Z][_a-zA-Z0-9]*`.
- **Expression**: `(atom s1 s2 ...)`, where *s1* is the first argument of atom, and it's an expression or a constant.
- *Separators*: It's recommended to use space `' '` (or newline), but `'|'` can be used instead.
- *Constants*: C constants (int, float, ...)

### Example

```java
(vsplit 
    (picker)
    (color 0xFF0000)
)
```

`vsplit` is a plugin with the expression `(picker)` as the left child, and the
expression `(color 0xFF0000)` as the right child. Then, by using the [[#ESX
API]], the `vsplit` plugin parses these expressions and execute on one side
`picker` and in the other side `color` with argument `0xFF0000`.

### Name Resolution

Because of the current implementation, names have to be of the form
`[_a-zA-Z][_a-zA-Z0-9]*`. This implies that you can't write a file path as the
plugin name. This behavior may be changed in the future. 

At the time of writing this, the name is resolved in the following order, being
`name` the literal text in the `esx` file:
1. `name`
2. `./plugins/name`
3. `name.so`
4. `./plugins/name.so`

In the future it's going to be more customizable.

### ESX API

*Esx* provides the following functions to interact with **esx** descriptions
given as a file or a string. They're part of eqnx. The signatures are the
following:
- `int esx_parse_file(char *filename, Esx_Program *prog);`
- `int esx_parse_string(char *buf, long buflen, Esx_Program *prog);`
- `int esx_to_args(Esx_Program program, int *e_argc, char ***e_argv);`

> **esx_parse_file**: 
> ```c 
> int esx_parse_file(char *filename, Esx_Program *prog);
> ```
>
> This function creates a program object that represents the same structure as
what is written in `filename` file.
> - *Filename* : Absolute or relative path to an *esx* program description file.
> - *Prog*: Pointer to a variable that is going to store the program.
> - ***Returns***: 0 on success, != 0 if something goes wrong.

> **esx_parse_string**: 
> ```c
> int esx_parse_string(char *buf, long buflen, Esx_Program *prog);
> ```
>
> This function creates a program object that represents the same structure as
what is written in the first `buflen` bytes of the `buf` string.
> - *Filename* : Absolute or relative path to an *esx* program description file.
> - *Prog*: Pointer to a variable that is going to store the program.
> - ***Returns***: 0 on success, != 0 if something goes wrong.

> **esx_to_args**: 
> ```c 
> int esx_to_args(Esx_Program program, int *e_argc, char ***e_argv);
> ```
>
> This function split the top expression of an *esx* program, being the atom the
> first argument and the constants or expressions in the same expression as the
> atom the rest of the arguments. `e_argv` is null terminated, so `e_argv[e_argc - 1] == NULL`.
> - *Program* : Loaded *esx* program. Have to be a valid program.
> - *e_argc*: Pointer to a variable that is going to store the argument count.
> - *e_argv*: Pointer to a variable that is going to store the argument values.
> - ***Returns***: 0 on success, != 0 if something goes wrong.

The fragment below converts the `esx program description` in `argv[1]` into
arguments, stored in `e_argv` with size `e_argc`. The first argument is the
atom, in this case the plugin name, and the next arguments are the constants or
expressions that follow it.

```c
Esx_Program prog;
int e_argc;
char **e_argv;

if (esx_parse_string(argv[1], strlen(argv[1]), &prog) || esx_to_args(prog, &e_argc, &e_argv)) {
        printf("Can not load esx file %s\n", argv[1]);
        exit(1);
}

```

## Eqnx API

> Create a child plugin and execute it. This function returns once `mainloop()` is
> called by the child. It returns either the plugin structure or NULL, if
> something went wrong. `Argv` is the array of startup values, `argv[0]` should be
> equal to `plugpath`, and last value of `argv` have to be **NULL**. `Argc` is the
> number of values in `argv`, also counting the null terminator.
> ```c
> Plugin *plug_run(char *plugpath, void *window, int argc, char **argv);
> ```

> Enter plugin *main loop*. It's not a loop, but acts like one. This function
> returns when the program has to end. Once this function is called, the plugin is
> going to start receiving events. 
> ```c
> void mainloop();
> ```

> This functions can be used by a plugin to propagate events to one of their
> children. `p` is a plugin created with `plug_run`, the rest of the arguments are
> caught throw the correspondent callback. These functions should be used inside
> the parent callback.
> ```c
> extern void plug_send_kp_event(Plugin *p, int sym, int mods);
> extern void plug_send_resize_event(Plugin *p, int x, int y, int w, int h);
> extern void plug_send_pointer_event(Plugin *p, Pointer_Event);
> extern void plug_render(Plugin *p);
> ```

> You can replace the plugin with other plugin. The plugin information would be
> reused, so for their parent and children it is still existing. After this call
> the new plugin starts from their main function. Once it calls `mainloop()`, the
> control returns to the main thread.
> ```c
> extern void plug_replace_img(Plugin *current, char *plugpath);
> ```

> Told the main thread to call the `render` callback on next iteration. It's
> needed to call this function in order to see any update in the screen.
> ```c
> extern void ask_for_redraw();
> ```

> The following group of functions can be used to update the screen.
> ```c
> extern void window_set(Window *window, int x, int y, uint32_t c, uint32_t fg, uint32_t bg);
> extern void window_setall(Window *window, uint32_t c, uint32_t fg, uint32_t bg);
> extern void window_puts(Window *window, int x, int y, uint32_t fg, uint32_t bg, char *str);
> extern void window_printf(Window *window, int x, int y, uint32_t fg, uint32_t bg, char *fmt, ...);
> extern void window_clear(Window *window, uint32_t fg, uint32_t bg);
> extern void window_clear_line(Window *window, int line, uint32_t fg, uint32_t bg);
> ```

> These functions are provided to swap between pixels and chars. Can be useful as
> resize arguments are in pixels.
> ```c
> extern void window_px_to_coords(int px, int py, int *x, int *y);
> extern void window_coords_to_px(int px, int py, int *x, int *y);
> ```

> Create a screen capture of the full screen and store it in a file named `filename` as a **png**.
> ```c
> extern int fb_capture(char *filename);
> ```

*You can always read the source code if you wish.*

## Architecture

### About plugins

A **plugin** is an independent program in [[#Language agnosticism|any
language]], that given events, produces output. Any plugin can define [[#Event
Callbacks|functions]] that, if defined, caught events. Who creates the plugin is
in charge of link plugin's functions to plugin's callback list. All this
information is stored in the `Plugin` struct. This is done automatically when
using the `plug_run()` call from any plugin to create and run a child plugin.
There are also some [[#Magic Global Variables]] that works the same.

All plugins have a single parent, that can be other plugin or the eqnx launcher.
A plugin can create and run other plugins. The `esx` programs are the bridge
between a parent, and it's child for passing arguments.

### About initialization

I'm going to give a high level overview of the program flow at initialization.

First, you run the native `eqnx` executable with an **esx** program `P`.
`Eqnx` creates an environment for simulating being a plugin for its first
child. Then it creates a `Plugin` information and runtime environment for the
first argument given by the **esx program** `P` ([[#ESX Program Descriptions]]).
Then, it executes this plugin.

1. When a plugin is created, a new coroutine is created. 
2. The default entry point for the coroutine is a trampoline to the `main()`
function of the plugin. 
3. Plugin's coroutine is used to execute it's `main()` until it reaches the
`mainloop()`. 
4. You should use the coroutine for initialization and deinitialization, all the
logic have to rely on callbacks. 
5. After that, every callback is called from the main thread, not from the
coroutine. 
6. The main Thread controls when and what coroutine is running.
7. All coroutines returns to the main thread. 
8. To create a new plugin, the function `plug_exec()`, used inside `plug_run()`,
returns the control to the main thread, with enough information to told it to
create and execute the child plugin. 
9. It runs until it reaches `mainloop()`, then the control is returned to the
main thread, who returns it to the plugin that calls `plug_exec()`. 
10. On plugin shutdown, `mainloop()` return and the coroutine has to return. 
11. It look's like if it's recursive, but it's not, the main thread is who
creates, starts and destroys any coroutine. 

### On callback
In the main thread a loop is executed. It blocks until it receive an event. Once
it's caught, it's send to the root plugin, the one that is executed the first on
startup. This plugin can propagate the event, or ignore it. It works
recursively, every parent has to send the events that their children is going to
receive.

## Language agnosticism

At the time of writing this, eqnx is designed to be language agnostic, but the
API is only provided in `C`. The plan for the future is to create bindings for
well known compiled languages, at least for `C++`, `rust` and `zig`. The main
idea is that although the core is totally in `C`, the plugins could be written in
any language, and they must be able to interact with plugins in any language
compatible with the eqnx architecture by design.

