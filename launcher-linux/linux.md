# Linecrafty on Linux

Back to the main [README](../README.md).

## What you need

- A ComfyUI install, either of these:
  - the [Comfy Desktop](https://www.comfy.org/download) AppImage (open it once so it finishes
    setting itself up), or
  - a normal [ComfyUI](https://github.com/comfyanonymous/ComfyUI) checkout with its own Python
    environment, e.g. `~/ComfyUI/venv`.
- ComfyUI's PyTorch must match your graphics card: the CUDA build for NVIDIA, the ROCm build for AMD.
- Python 3.8 or newer to run setup. Most distributions already have `python3`; if yours doesn't,
  `setup.sh` uses the Python inside ComfyUI instead.

### Disk space: ComfyUI can be much bigger on Linux

This is outside Linecrafty's control, but plan for it. On Windows with NVIDIA, Comfy Desktop is about
7 GB. On Linux, especially with AMD, ComfyUI can take **20-35 GB**:

- The AMD (ROCm) version of PyTorch is very large, because it bundles AMD's GPU libraries.
- The Comfy Desktop AppImage keeps **two** Python environments, `standalone-env` and
  `ComfyUI/.venv`, and each holds its own full copy of PyTorch.

That space belongs to ComfyUI, not Linecrafty, and it's on top of the ~18 GB of models Linecrafty
downloads. A manual ComfyUI checkout with a single venv avoids the second copy.

## Setup

From the Linecrafty folder:

```bash
./launcher-linux/setup.sh
```

If it says "Permission denied" (some zip tools drop the executable bit), run
`bash launcher-linux/setup.sh` instead. If your file manager runs scripts on double-click, that
works too: it opens a terminal window for the questions.

`setup.sh` just finds a Python and runs `setup.py`, so `python3 setup.py` does the same thing.
Arguments are passed through:

```bash
./launcher-linux/setup.sh ~/ComfyUI     # use this ComfyUI
./launcher-linux/setup.sh -y            # don't ask before downloading
```

Setup looks for Comfy Desktop's settings in `~/.config/Comfy Desktop` and for ComfyUI checkouts in
common places (`~/ComfyUI`, `~/dev/ComfyUI`, `/opt/ComfyUI` and so on). If it can't find yours, it
asks for the folder.

## Making pages

Run the script for the style you want, with your pictures (or folders of them):

```bash
python3 launcher-common/make_coloring_page.py photo.jpg other.png     # full line art
python3 launcher-common/make_simple_coloring_page.py photo.jpg        # fewer, bolder lines
python3 launcher-common/make_coloring_page_nobg.py photo.jpg          # just the characters
```

With no pictures they convert everything in the `input` folder and move the originals to
`input/done`. The `output` folder opens when it's done (using `xdg-open`).

For the command line, use `python3 linecrafty.py` wherever the main README says
`python linecrafty.py`.

## Troubleshooting

- **The output folder doesn't open**: that needs `xdg-open` (package `xdg-utils`). The pages are
  still in `output/`.
- **"didn't find a supported graphics card"** during setup: ComfyUI's PyTorch doesn't match your
  card (for example a CUDA build on an AMD card). Reinstall ComfyUI's PyTorch for your card.
