---
tags: guides, tools, zathura, todo
---

# How to set up and customize Zathura

<!-- Todo: add screen capture -->

[Zathura](https://pwmt.org/projects/zathura/) is a highly customizable and functional document viewer. It provides a minimalistic and space-saving interface as well as ease of use that mainly focuses on keyboard interaction.

zathura.tar.xz [download link](https://pwmt.org/projects/zathura/download/zathura-0.5.14.tar.xz)

## Customization

All customization is done by modifying `zathurarc`, placed in `~/.config/zathura/`. You have to create this file if it doesn't exist.

### Colors

The first thing, and the most important for ricers, are the colors. These colors apply to the background of the window, not the PDF. I use gruvbox material dark colors because that is what I use at the day of writing this.

```sh
# ui colors and font
set default-fg "#d4be98"
set default-bg "#1d2021"
set statusbar-fg "#d4be98"
set statusbar-bg "#1d2021"
set font "Iosevka NFM 18"

```

### PDF recolor (Zathura killer feature)

Zathura lets you change the background and foreground color of a PDF. I have it set by default because I want to keep my eyes sane. It's intended to be used with a dark theme, but instead, I use a relaxed white background with dark text because I prefer reading this way. The default command to toggle recolor is `C-r`.

```sh
# dark theme
set recolor true
set recolor-lightcolor "#888888"
set recolor-darkcolor  "#000000"

```

### Other settings

I increment the scroll step just for convenience.

```sh
# increment j-k scroll
set scroll-step 80

```

Sometimes the clipboard does not work; I don't know if this was fixed yet, but this line fixes it. To copy in Zathura, you only need to select text with the mouse, and it will be copied to the system clipboard.

```sh
set selection-clipboard clipboard

```

### Some mappings

I don't know why this is not the default; zooming should always be there.

```sh
# zoom
map <C-+> zoom in
map <C-=> zoom in
map <C--> zoom out

```

I also map some actions to where they are on Vimium, because they are easy to use in most cases, like `d` and `u` to scroll half the screen. The uppercase mappings are set there to make it easy to remember the mappings.

```sh
map u scroll half-up
map d scroll half-down
map D toggle_page_mode
map r reload
map R rotate
map F toggle_fullscreen
map [fullscreen] F toggle_fullscreen

```

## Final words

I really enjoy Zathura for reading PDFs. I have to use it a lot for college and I have never encountered a problem. It feels much better than the browser reader, which is what most people use, and I don't find any reason to avoid using an open-source PDF reader that works this well.


