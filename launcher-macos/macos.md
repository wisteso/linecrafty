# Linecrafty on macOS

Back to the main [README](../README.md).

**macOS isn't supported yet.** Nobody has tried it, and it may not work at all.

## Why not yet

- **The model format:** Linecrafty uses an fp8 ("8-bit") version of FLUX.1 Kontext, which fits on
  8 GB graphics cards. Apple-silicon GPUs may not support fp8 well, so the Mac version would
  probably need a different model file. That means a different download in `setup.py` and possibly
  different settings.
- **Nobody has tested it:** `setup.py` and `linecrafty.py` already have the macOS pieces (finding
  Comfy Desktop's settings in `~/Library/Application Support`, reading the memory size, opening
  the output folder with `open`), but none of it has been run on a Mac.
- **No double-click launchers:** there are no Mac launchers like the Windows `.cmd` files yet.

## If you want to try anyway

You'll need ComfyUI (the [Comfy Desktop](https://www.comfy.org/download) app for Mac, or a manual
install) and `python3`. Then, from the Linecrafty folder:

```bash
python3 setup.py
python3 launcher-common/make_coloring_page.py photo.jpg
```

Setup will warn that it didn't find an NVIDIA or AMD card, because it doesn't check for Apple GPUs
yet. If the model downloads fail with a certificate error and you installed Python from
python.org, run "Install Certificates.command" from its folder in Applications first.

If you try it, please open an issue on GitHub with what happened, including `comfy/server.log`.
