# Omarchy TTS Local

> **Local-only fork of [hikari112/omarchy-tts](https://github.com/hikari112/omarchy-tts).**
> Every cloud provider and OCR engine is removed, so nothing you read leaves
> this computer. It adds a fast Kokoro ONNX provider, a CPU/GPU choice for
> Kokoro, and a fix for false shortcut conflicts on Lua-configured Hyprland.
> See [CHANGELOG.md](CHANGELOG.md).

[![CI](https://github.com/jagrat7/omarchy-tts/actions/workflows/ci.yml/badge.svg)](https://github.com/jagrat7/omarchy-tts/actions/workflows/ci.yml)
[![License: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
[![Omarchy](https://img.shields.io/badge/Omarchy-Quattro-f97316.svg)](https://omarchy.org/)

**Anything on your screen can speak.**

Omarchy TTS Local turns speech into a desktop command: indicate something, hear it,
then stop. Read a selection, the clipboard, a clipboard image, a window, the
focused monitor, or a region you draw around otherwise unreachable text.

> Not a screen reader. Not a reading platform. Just a hotkey that makes the
> thing in front of you speak.

It is on-demand, local-only, and app-independent. Speech and screen reading
run on this computer, and nothing you read is sent anywhere. There is no
narration mode, account, subscription, API key, browser extension, or text
import workflow.

<p align="center">
  <img src="docs/screenshots/provider.png" alt="Omarchy TTS Local Provider tab showing the local speech providers" width="620">
</p>

## Why this exists

Sometimes you do not want the entire desktop narrated. You want *this paragraph*,
*this dialog*, or *this tiny line of game text* read once, immediately. Omarchy
TTS Local keeps that interaction consistent even when the source changes:

| What you indicate | What the plugin does |
|---|---|
| Selected or copied text | Reads the text directly |
| A copied image | Runs OCR (local by default), then reads the result |
| A dragged region | Captures those pixels, runs OCR, then reads them |
| The focused window or monitor | Captures it without requiring pointer precision |

This is assistive desktop reading for dyslexia, ADHD, low vision, eye strain,
reading fatigue, dense documentation, scanned PDFs, and unvoiced game text. It
complements structural screen readers such as Orca; it does not provide desktop
navigation, control semantics, or Braille support.

## Install

```bash
omarchy plugin add https://github.com/jagrat7/omarchy-tts.git --enable
```

Click the speaker in the bar. The welcome screen installs the recommended
local engine and voice; the **Keys** tab installs the shortcuts. Both are
guided, cancellable operations—no terminal setup or manual config editing.

Coming from `io.github.hikari112.tts` or an earlier build of this fork? The
first run moves `~/.config/omarchy-tts`, `~/.local/share/omarchy-tts` and
`~/.cache/omarchy-tts` to their `omarchy-tts-local` names, so installed
engines, voices and settings carry over. Remove the old plugin, then press
**Apply changes** on the Keys tab so the shortcuts point at the new one.

## Requirements

The base plugin uses `bash`, `wl-clipboard`, `jq`, `python3`, `flock`
(util-linux), and PipeWire or ALSA. Screen-reading modes additionally use
`tesseract`, `grim`, `slurp`, and optionally `hyprpicker`. Voice-catalogue
refreshes and downloads use `curl`. These system tools ship with Omarchy or are
installed from its configured Arch repositories.

The guided local-engine setup is always explicit. It may request administrator
approval through `pkexec` to install `uv` or a `tesseract-data-*` language
pack; `pkexec` and `pacman` are used only at their fixed system paths, checked
to be root-owned and unwritable by others immediately before each privileged
call, never resolved from `PATH`. Engines are built with `uv` into isolated
environments under `~/.local/share/omarchy-tts-local/` from complete, hash-pinned
dependency locks shipped in the plugin (`lib/engines/*.lock`, applied with
`uv pip sync --require-hashes`): Piper (`piper-tts==1.7.0`), Kokoro
(`kokoro==0.9.4` with its spaCy model wheel) and EasyOCR (`easyocr==1.7.2`),
all on Python 3.12 (`uv` fetches a checksummed interpreter if the system has
none). Model artefacts are pinned too: Piper voices
come from one revision of `rhasspy/piper-voices`, Kokoro's model, config and
voices from one revision of `hexgrad/Kokoro-82M`, and EasyOCR's recognition
models from fixed release archives, each verified against a SHA-256 shipped in
the plugin when downloaded and again before it is loaded. Every engine
environment records the lock that built it, so engines installed by a release
before 1.3.2 show as not installed until reinstalled once from the panel. Nothing is fetched
merely because the plugin is added or enabled, and no library is ever allowed
to download on its own.

## Keys

| Key | Action |
|-----|--------|
| `SUPER+ALT+E` | Speak the highlighted text (press again to stop) |
| `SUPER+ALT+A` | Speak clipboard text or a copied image |
| `SUPER+ALT+X` | Stop immediately |
| `SUPER+ALT+R` | **Drag a box, hear the text in it** (OCR) |
| `SUPER+ALT+W` | Read the focused window — no pointer needed |
| `SUPER+ALT+SHIFT+R` | Read the whole screen — no pointer needed |

## CLI

```bash
speak "hello world"           # speak an argument
cat notes.md | speak          # speak stdin
journalctl -n 20 | speak      # speak command output
speak --selection             # speak the highlighted text
speak --clipboard             # speak clipboard text, or OCR a clipboard image
speak --snip                  # drag a region, OCR it, speak it
speak --window                # read the focused window
speak --screen                # read the focused monitor
speak --ocr-engine easyocr --snip  # one capture through another engine
speak --stop                  # stop
speak --list                  # list providers
speak --provider kokoro       # override for one run
speak --verify kokoro         # prove a provider can speak (silent)
speak --verify-ocr easyocr    # prove an engine can read a known image
speak --refresh-languages     # re-read which OCR languages are installed
```

## Voices

```bash
speak-voice list                  # installed voices
speak-voice available             # 170+ voices, installed first
speak-voice available --json      # same, for scripting
speak-voice add en_GB-alba-medium # download (--async to background it)
speak-voice use en_GB-alba-medium # make it the default
speak-voice remove <voice>        # delete one
speak-voice status                # progress of a download in flight
speak-voice refresh               # check the shipped, pinned catalogue
speak-voice browse                # listen to samples in a browser
```

## Settings panel

Click the speaker in the bar. Right-click it to speak the selection without
opening anything, or to stop the current speech.

Six tabs, and a Test dock that stays visible on all of them so you can hear
a change straight after making it:

- **Provider** — every speech engine at once, each showing whether it
  actually works on this machine, with its CPU/GPU choice and uninstall.
- **Voice** — installed voice, speed, length limit, and **Browse all voices**:
  over 170 downloadable voices across 50+ languages, showing which
  are installed, with size and a one-click download that reports progress and
  verifies its SHA-256 against a digest shipped in the plugin before installing.
- **Text** — live before/after sanitizer preview and readability rules.
- **Screen** — OCR engine and confidence floor.
- **Languages** — which languages the selected engine recognises, and installing more.
- **Keys** — capture, install, update, or remove the plugin-owned shortcuts.

Settings write on change; there is no Save button. Configuration is created
on first use, migrated additively, written atomically, and kept mode 0600.
Everything the panel shows
comes from `speak --info`, and everything it changes goes through
the same CLI boundary: persisted settings use `speak --set`, while engine,
voice, and shortcut lifecycle actions use their dedicated commands. The
panel is therefore a front-end to the tested command-line implementation, not
a second implementation of it.

<details>
<summary>See the settings panel</summary>

| Provider | Voice |
|---|---|
| ![Provider status and devices](docs/screenshots/provider.png) | ![Voice, speed, and length settings](docs/screenshots/voice.png) |

| Text | Screen |
|---|---|
| ![Live sanitizer preview and text rules](docs/screenshots/text.png) | ![Recognition engines and the confidence floor](docs/screenshots/screen.png) |

| Languages | Keys |
|---|---|
| ![Recognition languages for the selected engine](docs/screenshots/languages.png) | ![Managed on-demand reading shortcuts](docs/screenshots/keys.png) |

The Languages view is separate from Screen so recognition-engine selection
and language-pack browsing remain focused tasks.

</details>

## Reading the screen (OCR)

Text in an image, a scanned PDF, a locked menu, a paused video frame — none of
it can be selected, so none of it can be read by conventional means. `--snip`
drags a box over it, runs OCR, and speaks the result.

```bash
speak --snip       # drag a region                  (pointer)
speak --window     # the focused window             (no pointer)
speak --screen     # the focused monitor            (no pointer)
```

`--clipboard` detects PNG, JPEG, WebP, BMP, or TIFF image-only clipboard
content and sends it through the selected OCR engine. Text is preferred when
an application places both text and image representations on the clipboard.

Because capture happens at the Wayland compositor level, region and window
reading can also work over fullscreen Steam/Proton games; it has been tested in
Cloudpunk. Capture behavior can still vary by compositor, game, and protected
surface, and the plugin makes no anti-cheat compatibility guarantee.

Two of the three need no pointer at all, which matters if dragging a box is
not an option for you.

### Recognition engines

Engines are chosen on the Screen tab the same way voices are: listed, proven,
then selected. Tesseract is the default; EasyOCR is an explicit opt-in. Both
read captures on this computer.

| Engine | Default | When to use it |
|---|---|---|
| `tesseract` | yes | Fast and deterministic on ordinary screen text. |
| `easyocr` | opt-in | Stylised, italic, or low-contrast text the default gives up on — game dialogue, posters, video frames. Costs about 6 GB of disk in a private Python environment and several seconds of model loading per capture. |
Languages are kept per engine. Tesseract combines any of its 120+ language
packs; EasyOCR pairs most languages only with English and reads a
`tesseract`-style code list through a mapping, so a selection tesseract accepts
is not silently reused for it. An engine asked for a language it does not have
stops and says so rather than reading garbage.

Engines live in `ocr/` and follow the same contract as voice providers: an
executable reading a PNG on stdin and writing text on stdout, with the same
`# desc:` / `# probe:` header. `~/.config/omarchy-tts-local/ocr/`
shadows the bundled ones. An engine is only reported ready after it has read
`lib/ocr-probe.png` correctly.

**Low-confidence words are discarded.** Engines report a per-word (or
per-line) confidence score, and anything below `ocr.minConfidence` (default 60) is dropped rather
than spoken. Someone using this to read a screen they cannot check has no way
to notice an invented word, so silence is preferred to noise. Set it to `0` to
keep everything.

OCR text is also reflowed before speaking: wrapped lines are rejoined into
paragraphs, words split across a line break are put back together, and stray
characters from neighbouring columns are dropped. Without that, a paragraph is
read back as one. short. burst. per. line.

## Providers

Bundled, all optional except piper:

| Provider | Notes |
|----------|-------|
| `piper` | **default** — neural, fast, ~60 MB/voice |
| `kokoro_onnx` | Kokoro voices on ONNX Runtime; under a second to start; **CPU** engine ~480 MB or **GPU** engine ~2.3 GB (CUDA libraries included); opt-in |
| `kokoro` | Kokoro on PyTorch; ~6 GB, several seconds to start every time; CPU or GPU; opt-in |
Both Kokoro providers share one **Kokoro** row in the Provider tab. Once more
than one is installed, a slider switches between them; **+** lists the ones
you do not have yet, with their size, and installs one inline. A freshly
installed engine is tested, then offered with **Switch** or **Later**.

Kokoro providers show a **Run on CPU / GPU** switch in the Provider tab
(`speak --set .kokoro_onnx.device gpu`). For `kokoro_onnx` the device picks
which engine is installed and used, so switching to GPU offers a separate
install; the two engines share one copy of the model files. The CPU engine
starts speaking slightly sooner on short selections; the GPU engine
synthesises long passages several times faster.
`kokoro_onnx` stays loaded in the background for 10 idle minutes so later
presses skip model loading (`speak --set .kokoro_onnx.keepWarm 0` to turn it
off; a warm GPU engine holds about 1.3 GB of video memory).

`espeak-ng` and Speech Dispatcher were removed in 1.3.0, and the cloud
providers (OpenAI, ElevenLabs, Gemini, Google Cloud Text-to-Speech) and cloud
OCR engines (OpenAI, Google Cloud Vision) in 2.0.0. A configuration that still
names one is moved to Piper or Tesseract on first run.

Public speech input is limited to 1 MiB and captured images to 50 MiB before
any processing, and a provider's declared character and byte limits are
enforced before it runs.

### Bring your own

A provider is any executable that reads text on stdin and plays it. A
`# title:` line gives it a display name; `# desc:` is a sentence or two shown
beneath it. Providers with the same `# family:` share a row as its variants,
labelled by `# variant:` and described by a short `# variantnote:`. Drop one
in `~/.config/omarchy-tts-local/providers/` and it shadows the bundled provider of
the same name.

```bash
#!/usr/bin/env bash
# desc: my custom voice
exec my-tts-engine --voice "${TTS_VOICE:-default}" --speed "${TTS_RATE:-1.0}"
```

Speech providers receive `TTS_VOICE`, `TTS_RATE`, `TTS_PLUGIN_DIR`,
`TTS_CONFIG`, `TTS_DATA_DIR`, `TTS_INPUT_CHARS`, and `TTS_INPUT_BYTES`.
Verification also sets `TTS_SILENT=1`: the provider must perform its strongest
non-audible readiness check, produce no sound, and exit zero only on success.
Providers that generate an audio stream can discard it.

## Remove

Before removing the plugin, use **Keys → Remove shortcuts** so no shortcuts
are left behind. If an earlier version stored cloud API keys in your keyring,
`speak-setup cleanup --yes` removes those along with the shortcuts. Then:

```bash
omarchy plugin remove io.github.jagrat7.omarchy-tts-local
```

Removal deliberately leaves downloaded engines, voice models, settings, and
cache data intact to avoid destroying user data. They remain clearly grouped
under `~/.local/share/omarchy-tts-local`, `~/.config/omarchy-tts-local`, and
`~/.cache/omarchy-tts-local` for optional manual cleanup.

## Config

`~/.config/omarchy-tts-local/config.json` — provider, voice, OCR, sanitizer, and UI
preferences. `rate` accepts 0.25–4.0; the panel narrows that range to what the
selected provider supports. `maxChars` accepts 0–1,048,576, where `0` means no
sanitizer truncation (the independent 1 MiB input safety limit still applies).
The current additive schema is version 5.

## The sanitizer

`lib/sanitize.py` is what makes this bearable. It strips ANSI escapes, Nerd
Font glyphs, and box drawing; flattens markdown tables into readable rows;
shortens paths to basenames; replaces hashes and UUIDs with a word; and
turns line breaks into sentence pauses. Selecting a 64-character SHA256 gets
you the word "hash", not thirty seconds of hex.

Test it standalone:

```bash
cat something.md | python3 ~/.config/omarchy/plugins/io.github.jagrat7.omarchy-tts-local/lib/sanitize.py
```

## Development

```bash
python3 -m unittest discover -s tests -v
python3 -m py_compile bin/speak-bindings bin/speak-setup lib/sanitize.py tests/*.py
shellcheck -x bin/speak bin/speak-voice providers/* ocr/* lib/*.sh
```

For hot reload during development, clone the repository and symlink that clone
to Omarchy's stable plugin location:

```bash
git clone https://github.com/jagrat7/omarchy-tts.git
ln -s "$PWD/omarchy-tts" \
  "${XDG_CONFIG_HOME:-$HOME/.config}/omarchy/plugins/io.github.jagrat7.omarchy-tts-local"
```

Saving a file in the clone then reloads the widget. The link command
intentionally fails when that plugin path already exists; use a disposable
profile or deliberately move an existing install aside before linking. Never
overwrite an existing plugin directory blindly.

## License

MIT — see [LICENSE](LICENSE).
