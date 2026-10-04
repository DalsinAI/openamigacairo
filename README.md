# openamigacairo

cairo and pixman for AmigaOS 3.x on 68k, built as static link libraries for
GCC programs. Part of the [OpenAmiga](https://github.com/DalsinAI/openamiga)
ports, made for [OpenBrowser](https://github.com/DalsinAI/openamigabrowser),
the WebKit browser for AmigaOS 3.2.

**Status:** Working: builds, and the smoke test draws correctly on the bench.

This repository holds the Amiga build, not cairo, pixman itself: a build script,
configuration headers, a smoke test and the upstream licences.

## Upstream

| Library | Version | Licence | Home |
| --- | --- | --- | --- |
| cairo | 1.18.6 | LGPL-2.1 or MPL-1.1, your choice (upstream/cairo/) | https://cairographics.org/ |
| pixman | 0.46.4 | MIT (upstream/pixman/COPYING) | https://pixman.org/ |

The exact files and their SHA-256 sums are in [SOURCES](SOURCES). All credit
for the library goes to its authors; see `upstream/` for their notices.

## What the Amiga port changes

- No source changes to either. pixman is built from its portable C paths (68k has no SIMD) with a hand-written `config/pixman/pixman-config.h`. cairo is built without Meson from its source list, with image surfaces, PNG writing and the FreeType/fontconfig font backend (`config/cairo/config.h`, `config/cairo/cairo-features.h`).

## Building

You need the os32-gcc16 compiler (bebbo's amiga-gcc on GCC 16.2 with libnix
and libpthread; see DalsinAI/openamigabrowser `stove/`) and the upstream
tarballs from [SOURCES](SOURCES) in `tarballs/`. Then:

```
./build.sh
```

The libraries and headers land in `out/` (set `PREFIX` to change that). The
script prints which other settings it needs, if any. Target: 68020 or better
with an FPU (`-m68020 -m68881`), libnix (`-mcrt=nix20`).

Link with: `-lcairo -lpixman-1 -lfontconfig -lfreetype -lexpat -lpng -lz -lpthread -latomic -lm`

## Tested

`tests/cairotest.c`, run on AmigaOS 3.2.3 on AmigaChrome's AC090 emulation (68040 with FPU, 256 MB), Instance-24, 4 October 2026, as `cairotest DH1:OBFonts/LiberationSans-Bold.ttf DH1:Probe/cairotest.png`:

```
CAIRO 1.18.6 status=no error has occurred sum=eb16d1e7 px(20,20)=ff4264d6 px(60,85)=ff4cb74c
PNG no error has occurred
```

It draws a linear gradient, a translucent anti-aliased circle and FreeType text into an ARGB32 image surface and saves it as PNG. The PNG the bench wrote shows the blue-to-red gradient, the green circle and "Amiga" in Liberation Sans Bold.

It has not yet been run on real Amiga hardware.

## Known issues

- **The FPU must be in double precision.** AmigaOS 3.2's ROM `mathieeesingbas.library` leaves the FPU in single precision (FPCR $40) in every task that opens it. cairo's fixed-point conversion then goes wrong and nothing is drawn. Set FPCR to 0 after opening libraries and in every thread, as `tests/cairotest.c` does.

## Licence

Dalsin Limited's Amiga changes (the build script, patches, configuration
headers and tests) are MIT, Copyright (c) 2026 Dalsin Limited: see
[LICENSE](LICENSE). cairo, pixman keep their own licences, in
[upstream/](upstream/); a patch to their source stays under that licence.
