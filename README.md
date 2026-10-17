# Omarchy TTS Local

[![CI](https://github.com/jagrat7/omarchy-tts/actions/workflows/ci.yml/badge.svg)](https://github.com/jagrat7/omarchy-tts/actions/workflows/ci.yml)
[![License: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
[![Omarchy](https://img.shields.io/badge/Omarchy-Quattro-f97316.svg)](https://omarchy.org/)

**Anything on your screen can speak, and nothing you read leaves your computer.**

An Omarchy bar plugin that turns speech into a desktop command: indicate
something, hear it, then stop. Read a selection, the clipboard, a copied image,
a window, the focused monitor, or a region you draw around text you cannot
select.

> Not a screen reader. Not a reading platform. Just a hotkey that makes the
> thing in front of you speak.

<p align="center">
  <img src="docs/screenshots/voice.png" alt="The Voice tab: installed voice, speed, length limit and a test dock" width="560">
</p>

## Highlights

- **Local only.** Speech and screen reading run on this computer. No account,
  subscription, API key or network call while you read.
- **One hotkey per source.** Selection, clipboard, a dragged region, the
  focused window or the whole monitor, each on its own shortcut.
- **Natural voices.** Piper by default, with 170+ downloadable voices in 50+
  languages, and Kokoro for higher quality on CPU or GPU.
- **Reads what you cannot select.** OCR for images, scanned PDFs, menus, video
  frames and game text, with low-confidence words dropped instead of guessed.
- **Text that sounds right.** A sanitizer turns markdown, code, URLs, hashes,
  units and terminal output into something worth listening to.
- **Guided setup.** The panel installs engines, voices and shortcuts for you,
  each step tested and cancellable. No terminal or config editing needed.

## Install

```bash
omarchy plugin add https://github.com/jagrat7/omarchy-tts.git --enable
```

Click the speaker in the bar. The welcome screen installs the recommended
voice (Piper, about 230 MB); the **Keys** tab sets up the shortcuts.

<details>
<summary>Moving from <code>io.github.hikari112.tts</code> or an earlier build</summary>

The first run moves `~/.config/omarchy-tts`, `~/.local/share/omarchy-tts` and
`~/.cache/omarchy-tts` to their `omarchy-tts-local` names, so installed engines,
voices and settings carry over. Remove the old plugin, then press **Apply
changes** on the Keys tab so the shortcuts point at this one. Any cloud provider
you had selected falls back to Piper.

</details>

## Keys

| Key | Action |
|-----|--------|
| `SUPER+ALT+E` | Speak the highlighted text (press again to stop) |
| `SUPER+ALT+A` | Speak clipboard text or a copied image |
| `SUPER+ALT+X` | Stop immediately |
| `SUPER+ALT+R` | **Drag a box, hear the text in it** (OCR) |
| `SUPER+ALT+W` | Read the focused window, no pointer needed |
| `SUPER+ALT+SHIFT+R` | Read the whole screen, no pointer needed |

Every shortcut can be changed from the Keys tab.

## Who it is for

Assistive desktop reading for dyslexia, ADHD, low vision, eye strain, reading
fatigue, dense documentation, scanned PDFs and unvoiced game text. It
complements structural screen readers such as Orca; it does not provide desktop
navigation, control semantics or Braille support.

| What you indicate | What the plugin does |
|---|---|
| Selected or copied text | Reads the text directly |
| A copied image | Runs OCR, then reads the result |
| A dragged region | Captures those pixels, runs OCR, then reads them |
| The focused window or monitor | Captures it without requiring pointer precision |

## Voices

| Provider | Size | Notes |
|----------|------|-------|
| Piper | ~230 MB, then ~60 MB per voice | **Default.** Neural, fast, 170+ voices to download |
| Kokoro ONNX | ~480 MB (CPU) or ~2.3 GB (GPU) | Higher quality, under a second to start. The GPU engine needs an NVIDIA card |
| Kokoro PyTorch | ~6 GB | Same voices on PyTorch; several seconds to start every time |

Both Kokoro engines share one **Kokoro** row in the Provider tab. Once two are
installed, a slider switches between them; **+** lists the ones you do not have
yet with their size and installs one in place. A new engine is tested before it
is offered, with **Switch** or **Later**. **Run on CPU / GPU** picks the device;
the Kokoro ONNX CPU and GPU engines share one copy of the model files. Kokoro
ONNX stays loaded for 10 idle minutes so later presses skip loading the model
(`speak --set .kokoro_onnx.keepWarm 0` turns that off).

Every provider is shown with whether it actually works on this machine: a
provider is only called ready after it has produced speech, and one that fails
in real use is marked as not working.

## Reading the screen (OCR)

```bash
speak --snip       # drag a region           (pointer)
speak --window     # the focused window      (no pointer)
speak --screen     # the focused monitor     (no pointer)
```

`--clipboard` reads a copied PNG, JPEG, WebP, BMP or TIFF through OCR, and
prefers text when the clipboard holds both. Capture happens at the Wayland
compositor, so region and window reading also works over fullscreen
Steam/Proton games. Behaviour can still vary by game and protected surface,
and there is no anti-cheat compatibility guarantee.

| Engine | Default | When to use it |
|---|---|---|
| Tesseract | yes | Fast and deterministic on ordinary screen text, 120+ language packs |
| EasyOCR | opt-in | Stylised, italic or low-contrast text: game dialogue, posters, video frames. About 6 GB, and several seconds of model loading per capture |

**Low-confidence words are dropped.** Anything below `ocr.minConfidence`
(default 60) is left out rather than spoken: someone reading a screen they
cannot check has no way to notice an invented word. Set it to `0` to keep
everything. Recognised text is reflowed before it is spoken, so wrapped lines
read as paragraphs rather than one. short. burst. per. line.

Languages are kept per engine and installed from the Languages tab. An engine
asked for a language it does not have stops and says so instead of reading
garbage.

## Settings panel

Click the speaker in the bar; right-click it to speak the selection or stop
without opening anything. Six tabs, with a test dock on all of them so you can
hear a change straight away:

- **Provider**: every speech engine, whether it works here, its device, and
  install or uninstall.
- **Voice**: voice, speed, length limit, and a browser for every downloadable
  voice.
- **Text**: a live before-and-after preview of the sanitizer and its rules.
- **Screen**: the OCR engine and the confidence floor.
- **Languages**: recognition languages for the selected engine.
- **Keys**: change, install or remove the shortcuts.

Settings save on change. Everything the panel shows comes from `speak --info`,
and everything it changes goes through the same command-line tools, so the
panel is a front end to the tested CLI rather than a second implementation.

<details>
<summary>More of the panel</summary>

| Text | Languages | Keys |
|---|---|---|
| ![Live sanitizer preview and text rules](docs/screenshots/text.png) | ![Recognition languages for the selected engine](docs/screenshots/languages.png) | ![Managed reading shortcuts](docs/screenshots/keys.png) |

</details>

## Command line

```bash
speak "hello world"                # speak an argument
cat notes.md | speak               # speak stdin
speak --selection                  # the highlighted text
speak --clipboard                  # clipboard text, or OCR a copied image
speak --stop                       # stop
speak --list                       # list providers
speak --provider kokoro_onnx       # use another provider for one run
speak --verify kokoro_onnx         # prove a provider can speak (silent)
speak --ocr-engine easyocr --snip  # one capture through another engine
speak --set .rate 1.2              # change a setting

speak-voice available              # every downloadable voice
speak-voice add en_GB-alba-medium  # download one
speak-voice use en_GB-alba-medium  # make it the default
```

`speak --help` and `speak-voice --help` list everything.

## The sanitizer

`lib/sanitize.py` is what makes this bearable. It strips ANSI escapes, Nerd
Font glyphs and box drawing; flattens markdown tables into readable rows;
shortens paths to basenames; replaces hashes and UUIDs with a word; and turns
line breaks into sentence pauses. Selecting a 64-character SHA-256 gets you
the word "hash", not thirty seconds of hex.

```bash
cat something.md | python3 ~/.config/omarchy/plugins/io.github.jagrat7.omarchy-tts-local/lib/sanitize.py
```

## Bring your own provider

A provider is any executable that reads text on stdin and plays it. Drop one in
`~/.config/omarchy-tts-local/providers/` and it shows up in the panel; a file
with the same name as a bundled provider replaces it.

```bash
#!/usr/bin/env bash
# title: My voice
# desc: my custom voice
exec my-tts-engine --voice "${TTS_VOICE:-default}" --speed "${TTS_RATE:-1.0}"
```

Providers receive `TTS_VOICE`, `TTS_RATE`, `TTS_PLUGIN_DIR`, `TTS_CONFIG`,
`TTS_DATA_DIR`, `TTS_INPUT_CHARS` and `TTS_INPUT_BYTES`. Verification sets
`TTS_SILENT=1`: the provider must check it can synthesise without making a
sound, and exit zero only on success. Providers with the same `# family:`
share a row as its variants, named by `# variant:` and described by a short
`# variantnote:`. OCR engines follow the same contract in
`~/.config/omarchy-tts-local/ocr/`, reading a PNG on stdin and writing text on
stdout.

## Requirements

`bash`, `wl-clipboard`, `jq`, `python3`, `flock` (util-linux) and PipeWire or
ALSA. Screen reading also uses `tesseract`, `grim`, `slurp` and optionally
`hyprpicker`; voice downloads use `curl`. All of these ship with Omarchy or come
from its Arch repositories.

## Privacy and security

- Nothing you read, select or capture is sent anywhere. The network is used
  only for installs and downloads you start: engines, models and voices.
- Every engine installs from hash-pinned dependency locks shipped with the
  plugin (`lib/engines/*.lock`) into its own environment under
  `~/.local/share/omarchy-tts-local/`. Models and voices are pinned to fixed
  sources and checked against SHA-256 digests in the plugin when downloaded and
  again before they load. No library is allowed to download on its own.
- Installing `uv` or a Tesseract language pack may ask for administrator
  approval through `pkexec`, used only at its fixed system path.
- Settings are written atomically and kept private (mode 0600). Input is capped
  at 1 MiB of text and 50 MiB of image.

See [SECURITY.md](SECURITY.md) for the full supply-chain description and how
to report a vulnerability.

## Remove

Use **Keys → Remove shortcuts** first, then:

```bash
omarchy plugin remove io.github.jagrat7.omarchy-tts-local
```

Downloaded engines, voices and settings are kept, under
`~/.local/share/omarchy-tts-local`, `~/.config/omarchy-tts-local` and
`~/.cache/omarchy-tts-local`, for you to delete if you want. If an earlier
version stored cloud API keys in your keyring, `speak-setup cleanup --yes`
removes them along with the shortcuts.

## Development

```bash
python3 -m unittest discover -s tests -v
python3 -m py_compile bin/speak-bindings bin/speak-setup lib/sanitize.py tests/*.py
shellcheck -x bin/speak bin/speak-voice providers/* ocr/* lib/*.sh
```

For hot reload, link a clone to Omarchy's plugin location:

```bash
git clone https://github.com/jagrat7/omarchy-tts.git
ln -s "$PWD/omarchy-tts" \
  "${XDG_CONFIG_HOME:-$HOME/.config}/omarchy/plugins/io.github.jagrat7.omarchy-tts-local"
```

The link fails if that path already exists; move an existing install aside
first rather than overwriting it. [DEVELOPMENT.md](DEVELOPMENT.md) covers the
architecture and a suggested review path.

## Credits

Based on [hikari112/omarchy-tts](https://github.com/hikari112/omarchy-tts),
with its cloud providers removed and Kokoro ONNX, CPU/GPU selection and
variant switching added. See [CHANGELOG.md](CHANGELOG.md).

## License

MIT, see [LICENSE](LICENSE).
