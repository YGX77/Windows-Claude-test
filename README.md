# Ladybird for Windows (unofficial, vibe-coded port)

> [!WARNING]
> **This is an unofficial, experimental Windows port of the [Ladybird](https://ladybird.org) browser, and yes, it is
> vibe coded** (written with AI help, using Claude Code). It is **not** made by, affiliated with, or endorsed by the
> Ladybird project. It builds and starts, but it **needs fixes**, and a lot of it has not been tested. Here you go,
> guys. Please be kind, and help if you can.

Ladybird is a truly independent web browser with its own engine. Upstream's Windows story is "use WSL2" or an
experimental native build. This repository makes the native build produce something you can actually download and run.

## Download

Get the latest from the [Releases page](../../releases). The current one is
[**v0.1.2**](../../releases/tag/v0.1.2):

- [`Ladybird-Setup.exe`](../../releases/download/v0.1.2/Ladybird-Setup.exe): installer (Start menu and desktop shortcut,
  uninstaller, installs for your user only, no administrator prompt).
- [`Ladybird-windows-x64.zip`](../../releases/download/v0.1.2/Ladybird-windows-x64.zip): no install. Unzip it, open the
  `bin` folder and run `Ladybird.exe`. Keep the folder together.

Windows will probably show a blue **"Windows protected your PC"** box, because the installer is not code-signed.
Click **More info**, then **Run anyway**.

Requires 64-bit Windows (x86_64). There is no ARM build yet. The v0.1.0 and v0.1.1 releases are broken (missing
files); use v0.1.2 or newer.

## Status: what works and what doesn't

Honest version:

- The Windows build compiles in CI with `clang-cl`, every DLL the program needs is shipped (a CI check fails the build
  if one is missing), and CI starts `Ladybird.exe` once and checks that it stays running and loads Qt.
- **Beyond that, little is verified.** Real-world browsing, rendering, video, downloads, devtools and so on are untested
  on real machines. Expect crashes and missing features.
- Upstream itself labels its Windows build *"experimental ... minimal runtime support"*.

If something breaks, please [open an issue](../../issues) here (not on upstream Ladybird: they don't support this
port) with what you did and any error message or screenshot.

## What this port changes

On top of upstream Ladybird:

- **LibCore (Windows layer), fixes to unfinished spots:**
  - Opening a file with `Nonblocking` no longer crashes (it is ignored, as on POSIX regular files).
  - `File::stat(path)` follows symlinks (reparse points) like POSIX `stat()`.
  - Sockets: `set_blocking` works, non-blocking `write` is honoured, and `TCPSocket::connect(host, port)` tries every
    resolved address instead of only the first.
  - `Process::spawn` passes a custom environment to the child process.
- **Install layout:** on Windows, helper processes install next to `Ladybird.exe` (where the program looks for them)
  instead of in `libexec/`.
- **Packaging:** the Qt and vcpkg DLLs, Qt's plugins and the Visual C++ runtime are bundled, and a check
  ([`check_dlls.py`](.github/windows/check_dlls.py)) fails the build if any needed DLL is missing.
- **CI:** [`windows-exe.yml`](.github/workflows/windows-exe.yml) builds and publishes the release;
  [`windows-installer.yml`](.github/workflows/windows-installer.yml) turns it into the installer.

Not done (still marked `FIXME` in the code): memory-pressure and process-statistics support on Windows, a few
other rough edges in `Libraries/LibCore/*Windows.cpp`, and anything specific to ARM64.

## Build it yourself

The build recipe that is known to work is the CI workflow, [`windows-exe.yml`](.github/workflows/windows-exe.yml).
In short, on Windows with Visual Studio 2022 (C++ tools), LLVM 20 (`clang-cl`), CMake, Ninja, Python 3, `pkgconfiglite`
and Rust installed, from a Visual Studio x64 developer prompt:

```
py Meta\ladybird.py vcpkg --preset Release
cmake --preset Release -B Build -DLADYBIRD_BASELINE_CPU_TARGET=ON
cmake --build Build
```

The first build downloads and builds every dependency, which takes about an hour (about two with the compile). Newer
Visual Studio versions (18) need a newer LLVM than 20 and will fail. The upstream
[build instructions](Documentation/BuildInstructionsLadybird.md) have more detail.

## Credits and license

All the real work is by the [Ladybird developers](https://github.com/LadybirdBrowser/ladybird) and the SerenityOS
community. This repository is a derivative of their work and keeps their license: Ladybird is under the 2-clause BSD
license (see [`LICENSE`](LICENSE)). The Windows downloads also bundle third-party libraries (Qt, Skia, FFmpeg, ICU,
OpenSSL, curl and others) that keep their own licenses; see [`.github/windows/NOTICE.txt`](.github/windows/NOTICE.txt),
which is also included in the downloads.

---

## About upstream Ladybird

The rest of this page is upstream's README, kept for reference.

[Ladybird](https://ladybird.org) is a truly independent web browser, using a novel engine based on web standards.

> [!IMPORTANT]
> Ladybird is in a pre-alpha state, and only suitable for use by developers
>

### Features

We aim to build a complete, usable browser for the modern web.

Ladybird uses a [multi-process architecture](Documentation/ProcessArchitecture.md) with a main UI process,
WebContent renderer processes, and helper processes for tasks such as networking, image decoding, compositing and media.

Documents from different sites run in separate renderer processes, each sandboxed from the rest of the system.
Image decoding and network connections are done out of process, separately for each site, to be more robust against
malicious content.

At the moment, many core library support components are inherited from SerenityOS:

- LibWeb: Web rendering engine
- LibJS: JavaScript engine
- LibWasm: WebAssembly implementation
- LibCrypto/LibTLS: Cryptography primitives and Transport Layer Security
- LibHTTP: HTTP/1.1 client
- LibGfx: 2D Graphics Library, Image Decoding and Rendering
- LibUnicode: Unicode and locale support
- LibMedia: Audio and video playback
- LibCore: Event loop, OS abstraction layer
- LibIPC: Inter-process communication

### How do I build and run this?

See [build instructions](Documentation/BuildInstructionsLadybird.md) for information on how to build Ladybird.

Upstream Ladybird runs on Linux, macOS, Windows (with WSL2), and many other \*Nixes. This repository adds a native Windows build, described above.

### How do I read the documentation?

Code-related documentation can be found in the [documentation](Documentation/) folder.

### Get in touch and participate!

Join [our Discord server](https://discord.gg/nvfjVJ4Svh) to participate in issue and development discussions.

Please read [Getting involved with Ladybird](Documentation/GettingStartedContributing.md) if you're new to Ladybird and want to help.

Before opening an issue, please see the [issue policy](CONTRIBUTING.md#issue-policy) and the [detailed issue-reporting guidelines](ISSUES.md).

The project participation guidelines can be found in [`CONTRIBUTING.md`](CONTRIBUTING.md).

### License

Ladybird is licensed under a 2-clause BSD license.
