# Linecrafty

Turn any color picture into a clean black-and-white **coloring-book page** with local AI that runs
entirely on your own Windows or Linux PC. Nothing is uploaded anywhere, and no account or cloud service is
involved. After setup, it doesn't even need the internet.

It isn't an edge-detection filter. A local AI image-editing model (**FLUX.1 Kontext [dev]**, run on
your own graphics card through [ComfyUI](https://www.comfy.org)) redraws the picture as line art the way a coloring-book artist would:
closed shapes, smooth outlines, no shading. The result is then upscaled 4x and cleaned to pure black
on white, ready to print. It can also trace it to a vector SVG that stays sharp at any size.

Three styles:

| Style | What you get |
|---|---|
| **full** (default) | Characters plus the whole background, redrawn as line art |
| **simple** | Fewer, bolder lines and big open areas, for little kids |
| **nobg** | Just the characters on white, no scenery |

## What you need

- **Windows or Linux.** macOS isn't supported yet.
- An **NVIDIA or AMD** graphics card with 8 GB or more of video memory
  - NVIDIA: RTX 3060 / 3070 / 4060 or better. Tested.
  - AMD: Radeon RX 7700 XT / 7800 XT / 7900 or better, using ComfyUI's AMD (ROCm) version. Being
    tested; please report how it goes.
- System memory (RAM):
  - **32 GB recommended**
  - **16 GB minimum**: should work, but pages take longer; close other programs while it runs.
    Not yet tested; we'd like to hear how it goes.
- About 18 GB of free disk space for the local AI models, plus room for ComfyUI itself. ComfyUI's
  size depends a lot on your system: about 7 GB on Windows, and up to 20-35 GB on Linux (see the
  Linux guide).
- **[ComfyUI](https://www.comfy.org/download)**, the engine that runs the local AI model. The
  [Comfy Desktop app](https://www.comfy.org/download) is the easiest: install it and open it once
  so it finishes setting itself up. You can close it afterwards.

Your system's guide has the details:

| System | Guide | Status |
|---|---|---|
| Windows 10 / 11 | [launcher-windows/windows.md](launcher-windows/windows.md) | Tested |
| Linux | [launcher-linux/linux.md](launcher-linux/linux.md) | Tested with AMD |
| macOS | [launcher-macos/macos.md](launcher-macos/macos.md) | Not supported yet |

## Setup (once)

1. Get Linecrafty: the green **Code** button above > **Download ZIP**, then unzip it somewhere with
   ~18 GB free. Or `git clone https://github.com/wisteso/linecrafty`.
2. Run setup as your system's guide describes: `launcher-windows\setup.cmd` on Windows,
   `launcher-linux/setup.sh` on Linux.

Setup finds your ComfyUI (if it can't, it asks you for the folder), checks your graphics card and
memory, and downloads the local AI models (~17.7 GB). It asks before downloading, verifies every
file against its SHA-256 hash, and resumes if interrupted: just run setup again. It never changes
your ComfyUI install; the only thing it installs is the small `vtracer` library, into this folder's
`lib/`.

## Making pages

There's one launcher per style, so you don't need any options for everyday use:

| Style | Windows (drag pictures onto it) | Linux (`python3 ...` with pictures) |
|---|---|---|
| full | `Make Coloring Page.cmd` | `launcher-common/make_coloring_page.py` |
| simple | `Make Simple Coloring Page.cmd` | `launcher-common/make_simple_coloring_page.py` |
| nobg | `Make Coloring Page (no background).cmd` | `launcher-common/make_coloring_page_nobg.py` |

Run with no pictures, they convert everything in the `input` folder and move the originals to
`input/done`.

A page takes about 2-4 minutes (simple: about 1 minute) on an 8 GB card. When it's done, the
`output` folder opens. For each picture you get:

| File | |
|---|---|
| `name_lineart.png` | The coloring page, 3328x4992. Print this one. |
| `name_raw.png` | The local AI's direct output, before cleanup |
| `name_lineart.svg` | Only with `--svg` (command line): vector version, sharp at any size |

Every run draws a slightly different version, so if you don't like one, run it again.

## Command line

`linecrafty.py` is the underlying tool (`python linecrafty.py --help` for everything). It works with
any Python: it re-launches itself under ComfyUI's Python, which setup remembered. (Windows without a
Python of your own: use `launcher-windows\linecrafty.cmd` instead; see the Windows guide.)

```
python linecrafty.py photo.jpg                       # full style -> output/
python linecrafty.py photo.jpg --style all           # full + simple + nobg
python linecrafty.py photo.jpg --variants 3          # three different takes
python linecrafty.py photo.jpg --svg                 # also write a vector SVG
python linecrafty.py photo.jpg --extra "Leave out the dog."
python linecrafty.py some/folder -o some/pages       # a whole folder
python linecrafty.py photo.jpg --keep-server         # keep models loaded; later runs start faster
python linecrafty.py --stop                          # unload them
```

Fine-tuning:

| Option | Default | What it does |
|---|---|---|
| `--extra "TEXT"` | none | Extra plain-English instruction, e.g. `--extra "Give her a crown."` |
| `--seed N` | random | Same picture + seed + settings = same page again |
| `--steps N` | 24 | Refinement passes, 16-32. Fewer = faster drafts, more = slightly cleaner |
| `--guidance N` | 2.5 | How literally the instruction is followed, 1.5-4.0. Raise it if color or shading sneaks through |
| `--black 0-255` | 90 | Brightness (0 = black, 255 = white) at or below which grey becomes solid ink. Raise for bolder lines |
| `--white 0-255` | 200 | Brightness at or above which grey becomes white paper. Lower it to wipe out faint smudges |
| `--speck PIXELS` | 60 | Removes isolated ink dots smaller than this many pixels (60 px is about 0.5 mm printed) |

## Repo layout

```
linecrafty.py       the tool itself
setup.py            one-time setup (finds ComfyUI, downloads models, installs the SVG tracer)
launcher-common/    make_coloring_page.py and its simple / no-background variants (any OS)
launcher-windows/   windows.md, setup.cmd, linecrafty.cmd and the drag-and-drop .cmd files
launcher-linux/     linux.md and setup.sh
launcher-macos/     macos.md (not supported yet)
input/ output/      your pictures and the finished pages (created by setup)
models/ lib/        downloaded AI models and the SVG tracer (created by setup)
config.json         where your ComfyUI is (written by setup)
```

Everything is plain Python using only the standard library (plus numpy, Pillow and SciPy from
ComfyUI's environment), so the same files run on every system. The `.cmd` and `.sh` files are thin
wrappers that find a Python to run them with.

## How it works

1. `linecrafty.py` starts its own hidden ComfyUI (using your install's code and Python) on port 8288,
   with custom nodes disabled and its own input/output/user folders under `comfy/`. Your ComfyUI's
   settings and workflows are untouched.
2. FLUX.1 Kontext dev (fp8) gets the picture plus an instruction prompt (see `STYLES` in
   `linecrafty.py`). "simple" also runs at ~0.3 MP, because the model ignores "use fewer lines" but
   can't fit fine detail into fewer pixels.
3. 4x-AnimeSharp upscales the result 4x.
4. Levels push grey to pure black or white, small specks are removed, and with `--svg` vtracer traces the SVG.

`config.json` (written by setup) records which ComfyUI to use. Re-run setup if you move or
reinstall ComfyUI, or point it somewhere specific (see Setup).

## Models

Downloaded by setup from Hugging Face. They aren't included in this repository.

| File | Size | Source | License |
|---|---|---|---|
| `flux1-dev-kontext_fp8_scaled.safetensors` | 11.9 GB | [Comfy-Org/Flux-1-Kontext-Dev](https://huggingface.co/Comfy-Org/Flux-1-Kontext-Dev) (Black Forest Labs) | [FLUX.1 [dev] Non-Commercial](https://huggingface.co/black-forest-labs/FLUX.1-Kontext-dev/blob/main/LICENSE.md) |
| `t5xxl_fp8_e4m3fn_scaled.safetensors` | 5.2 GB | [comfyanonymous/flux_text_encoders](https://huggingface.co/comfyanonymous/flux_text_encoders) | Apache-2.0 |
| `clip_l.safetensors` | 0.2 GB | [comfyanonymous/flux_text_encoders](https://huggingface.co/comfyanonymous/flux_text_encoders) | Apache-2.0 |
| `ae.safetensors` (FLUX VAE) | 0.3 GB | [Comfy-Org/Lumina_Image_2.0_Repackaged](https://huggingface.co/Comfy-Org/Lumina_Image_2.0_Repackaged) | Apache-2.0 |
| `4x-AnimeSharp.pth` | 0.1 GB | [Kim2091/AnimeSharp](https://huggingface.co/Kim2091/AnimeSharp) by Kim2091 | [CC BY-NC-SA 4.0](https://creativecommons.org/licenses/by-nc-sa/4.0/) |

If a model is already in your ComfyUI models folder (or Comfy Desktop's shared models folder), setup
uses it instead of downloading it again.

## License

Linecrafty's own code (the scripts in this repository) is [MIT licensed](LICENSE).

The local AI models are **not** part of this repository and are **not** covered by that license. Setup
downloads them from their original sources, and each has its own terms (table above). Two of them,
**FLUX.1 Kontext [dev]** and **4x-AnimeSharp**, are licensed for **non-commercial use only**. So the
coloring pages Linecrafty makes with them are for personal use: print them, color them, share them
with friends, but don't sell them. By running setup you're downloading those models and
agreeing to their licenses.

Linecrafty runs your separately installed [ComfyUI](https://github.com/comfyanonymous/ComfyUI)
(GPL-3.0) as its own program and talks to it over its local API. It doesn't include or modify any
ComfyUI code. It also uses NumPy, SciPy and Pillow from ComfyUI's Python, and installs
[vtracer](https://github.com/visioncortex/vtracer) (MIT).

## Troubleshooting

- **"Not set up yet"**: run setup (see your system's guide).
- **"ComfyUI exited during startup"**: see `comfy/server.log`. ComfyUI usually needs updating; update
  it, then re-run setup.
- **Very slow or out of memory**: close other big programs (games, browsers with many tabs).
- **Moved or reinstalled ComfyUI**: re-run setup.
- System-specific problems are in your system's guide.
