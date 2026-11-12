# Linecrafty on Windows

Back to the main [README](../README.md).

## What you need

- Windows 10 or 11
- The [Comfy Desktop app](https://www.comfy.org/download): install it and open it once so it
  finishes setting itself up. You can close it afterwards. A portable ComfyUI or the older ComfyUI
  desktop app works too.
- Nothing else: setup runs on the Python that comes with ComfyUI, so you don't need to install
  Python yourself.

Comfy Desktop itself takes about 7 GB (with an NVIDIA card), on top of the ~18 GB of models
Linecrafty downloads.

## Setup

1. Download and unzip Linecrafty (see the main README).
   If Windows warns about running the files, right-click the zip > Properties > tick **Unblock**
   before unzipping.
2. Double-click **`launcher-windows\setup.cmd`**.

To use a specific ComfyUI, give its folder from a Command Prompt:

```bat
launcher-windows\setup.cmd "D:\ComfyUI_windows_portable"
```

Add `-y` to skip the download question. Re-run `setup.cmd` any time you move or reinstall ComfyUI.

## Making pages

Drag one or more pictures (or a folder of them) onto one of these in `launcher-windows`:

- **`Make Coloring Page.cmd`**: full line art, the usual choice
- **`Make Simple Coloring Page.cmd`**: fewer, bolder lines
- **`Make Coloring Page (no background).cmd`**: just the characters

Or put pictures in the `input` folder and double-click one of them. It converts them all and moves
them to `input\done`. The `output` folder opens when it's done.

Tip: right-click `Make Coloring Page.cmd` > Send to > Desktop (create shortcut), and drag pictures
onto the shortcut.

## Command line

`launcher-windows\linecrafty.cmd` runs the tool with ComfyUI's Python, so it works even if you have
no Python of your own. Use it wherever the main README says `python linecrafty.py`:

```bat
launcher-windows\linecrafty.cmd photo.jpg --style all --svg
launcher-windows\linecrafty.cmd --help
```

If you do have Python installed (from python.org), `py linecrafty.py ...` works the same way.

## Troubleshooting

- **"Couldn't find Python or Comfy Desktop"** from `setup.cmd`: install Comfy Desktop and open it
  once, or install Python from [python.org](https://www.python.org/downloads/), then run it again.
- **"Not set up yet"**: run `launcher-windows\setup.cmd`.
- **Windows SmartScreen or "blocked" warnings**: unblock the zip before unzipping (see Setup).
  `setup.cmd` also unblocks Linecrafty's own files when it runs.
