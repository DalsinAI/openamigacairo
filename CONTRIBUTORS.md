# Contributors

## Creator and maintainer

- **SacredTrees** ([@SacredTrees](https://github.com/SacredTrees)): created and maintains this AmigaOS port of cairo and pixman (openamigacairo).

## The AmigaChrome team

We are the AI agents who build AmigaChrome alongside SacredTrees:

- **Agnus**, our coordinator, who keeps every thread moving.
- **Thufir**, **Kynes** and **Galen**, the earlier agents who started the work on SacredTrees's x86 cores.
- **The Claude Code threads**, each one taking a piece of the work from design to release.

## Copyright holder

Our Amiga work here (the build script, the configuration headers in
`config/` and the test) is Copyright (c) 2026 Dalsin Limited, released under
the MIT licence (`LICENSE`). cairo and pixman are not ours: they stay
copyright their authors under their own licences.

## Third-party work in this repository

Only the upstream licence texts and author lists are committed here; the
libraries' source is not.

| Component | Where | Authors | Licence |
| --- | --- | --- | --- |
| cairo licence texts and author list | `upstream/cairo/COPYING`, `COPYING-LGPL-2.1`, `COPYING-MPL-1.1`, `AUTHORS` | Carl Worth, Keith Packard and the cairo authors (`upstream/cairo/AUTHORS`) | LGPL-2.1 or MPL-1.1, your choice |
| pixman licence | `upstream/pixman/COPYING` | The pixman copyright holders listed there, among them Keith Packard, Red Hat, The Open Group and Trolltech | MIT |

## Fetched at build time, not committed

`build.sh` unpacks these tarballs, listed with their SHA-256 sums in `SOURCES`:

- **cairo 1.18.6** (`cairo-1.18.6.tar.xz`): Carl Worth, Keith Packard and the cairo authors, LGPL-2.1 or MPL-1.1.
- **pixman 0.46.4** (`pixman-0.46.4.tar.gz`): the pixman authors, MIT.

## Used at build time, not included

- **FreeType**, **fontconfig**, **libpng** and **zlib**, each under its own licence.
- **bebbo's amiga-gcc** (GCC 16.2 with libnix and libpthread), the os32-gcc16 compiler, under its own licences.

Amiga, AmigaOS and other product names are trademarks of their respective
owners.
