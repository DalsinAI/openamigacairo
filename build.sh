#!/bin/sh
# openamigacairo: cairo and pixman, built for AmigaOS 3.x (68020 + FPU) with the
# os32-gcc16 compiler (bebbo's amiga-gcc, GCC 16.2, libnix, libpthread).
# MIT, Copyright (c) 2026 Dalsin Limited. The library keeps its own licence.
#
#   OS32_GCC16   compiler root holding prefix/ and compat/
#                (default ~/AmigaChrome/stoves/os32-gcc16)
#   PREFIX       where include/ and lib/ go (default ./out)
#   TARBALLS     folder holding the upstream tarballs listed in SOURCES
#                (default ./tarballs); the script checks their SHA-256
#   JOBS         parallel jobs for CMake/make builds (default 2)
#
# usage: ./build.sh
set -eu
HERE=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
S=${OS32_GCC16:-"$HOME/AmigaChrome/stoves/os32-gcc16"}
P=$S/prefix
OUT=${PREFIX:-"$HERE/out"}
TARBALLS=${TARBALLS:-"$HERE/tarballs"}
JOBS=${JOBS:-2}
WORK="$HERE/work"
CC="$P/bin/m68k-amigaos-gcc"
CXX="$P/bin/m68k-amigaos-g++"
AR="$P/bin/m68k-amigaos-ar"
CPU=${OS32_CPU_FLAGS:-"-m68020 -m68881 -mcrt=nix20"}
CFLAGS="-O2 $CPU -D_DEFAULT_SOURCE=1 -D_POSIX_TIMERS=1 -D_POSIX_REALTIME_SIGNALS=1 -fno-common"
mkdir -p "$OUT/include" "$OUT/lib" "$WORK"

# unpack NAME TARBALL SHA256: check the tarball and unpack it into $WORK
unpack() {
    t="$TARBALLS/$2"
    [ -f "$t" ] || { echo "missing $t (see SOURCES)"; exit 2; }
    echo "$3  $t" | sha256sum -c - >/dev/null || { echo "SHA-256 mismatch: $t"; exit 2; }
    rm -rf "$WORK/$1"; mkdir -p "$WORK/$1"
    case "$2" in
        *.zip) (cd "$WORK/$1" && unzip -q "$t") ;;
        *) tar xf "$t" -C "$WORK/$1" ;;
    esac
}

# archive NAME FILE...: compile into $OUT/lib/libNAME.a ($XFLAGS added)
archive() {
    name=$1; shift
    obj="$WORK/obj-$name"
    rm -rf "$obj"; mkdir -p "$obj"
    for f in "$@"; do
        o="$obj/$(echo "$f" | tr '/' '_' | sed 's/\.[a-z]*$//').o"
        # GCC 16.2 stops with an internal error (reload, gen_rtx_SUBREG) on
        # this file at -O2 with -m68020-60; -Os compiles it.
        extra=
        case "$f" in *cairo-mesh-pattern-rasterizer.c) extra=-Os ;; esac
        case "$f" in
            *.cc|*.cpp) $CXX $CFLAGS ${XFLAGS:-} $extra -c "$f" -o "$o" ;;
            *) $CC $CFLAGS ${XFLAGS:-} $extra -c "$f" -o "$o" ;;
        esac
    done
    rm -f "$OUT/lib/lib$name.a"
    $AR rcs "$OUT/lib/lib$name.a" "$obj"/*.o
    echo "lib$name.a: $(wc -c < "$OUT/lib/lib$name.a") bytes"
}

DEPS=${DEPS_PREFIX:?set DEPS_PREFIX to a prefix with FreeType, fontconfig, libpng and zlib}
unpack pixman pixman-0.46.4.tar.gz d09c44ebc3bd5bee7021c79f922fe8fb2fb57f7320f55e97ff9914d2346a591c
cd "$WORK/pixman/pixman-0.46.4"
sed -e 's/@PIXMAN_VERSION_MAJOR@/0/; s/@PIXMAN_VERSION_MINOR@/46/; s/@PIXMAN_VERSION_MICRO@/4/' \
    pixman/pixman-version.h.in > "$HERE/config/pixman/pixman-version.h"
XFLAGS="-I$HERE/config/pixman -Ipixman -DHAVE_CONFIG_H" archive pixman-1 \
    pixman/pixman.c \
    pixman/pixman-access.c \
    pixman/pixman-access-accessors.c \
    pixman/pixman-arm.c \
    pixman/pixman-bits-image.c \
    pixman/pixman-combine32.c \
    pixman/pixman-combine-float.c \
    pixman/pixman-conical-gradient.c \
    pixman/pixman-edge.c \
    pixman/pixman-edge-accessors.c \
    pixman/pixman-fast-path.c \
    pixman/pixman-filter.c \
    pixman/pixman-glyph.c \
    pixman/pixman-general.c \
    pixman/pixman-gradient-walker.c \
    pixman/pixman-image.c \
    pixman/pixman-implementation.c \
    pixman/pixman-linear-gradient.c \
    pixman/pixman-matrix.c \
    pixman/pixman-mips.c \
    pixman/pixman-noop.c \
    pixman/pixman-ppc.c \
    pixman/pixman-radial-gradient.c \
    pixman/pixman-region16.c \
    pixman/pixman-region32.c \
    pixman/pixman-region64f.c \
    pixman/pixman-riscv.c \
    pixman/pixman-solid-fill.c \
    pixman/pixman-timer.c \
    pixman/pixman-trap.c \
    pixman/pixman-utils.c \
    pixman/pixman-x86.c
mkdir -p "$OUT/include/pixman-1"
cp pixman/pixman.h "$HERE/config/pixman/pixman-version.h" "$OUT/include/pixman-1/"

unpack cairo cairo-1.18.6.tar.xz 1c767308174337a74694da0f3ec069c271452163a1ef4540964c50c301f157d4
cd "$WORK/cairo/cairo-1.18.6"
XFLAGS="-include pthread.h -DHAVE_CONFIG_H -DCAIRO_COMPILATION -I$HERE/config/cairo -Isrc -I$DEPS/include \
    -I$OUT/include/pixman-1 -I$DEPS/include/freetype2" archive cairo \
    src/cairo-analysis-surface.c \
    src/cairo-arc.c \
    src/cairo-array.c \
    src/cairo-atomic.c \
    src/cairo-base64-stream.c \
    src/cairo-base85-stream.c \
    src/cairo-bentley-ottmann-rectangular.c \
    src/cairo-bentley-ottmann-rectilinear.c \
    src/cairo-bentley-ottmann.c \
    src/cairo-botor-scan-converter.c \
    src/cairo-boxes-intersect.c \
    src/cairo-boxes.c \
    src/cairo-cache.c \
    src/cairo-clip-boxes.c \
    src/cairo-clip-polygon.c \
    src/cairo-clip-region.c \
    src/cairo-clip-surface.c \
    src/cairo-clip-tor-scan-converter.c \
    src/cairo-clip.c \
    src/cairo-color.c \
    src/cairo-composite-rectangles.c \
    src/cairo-compositor.c \
    src/cairo-contour.c \
    src/cairo-damage.c \
    src/cairo-debug.c \
    src/cairo-default-context.c \
    src/cairo-device.c \
    src/cairo-error.c \
    src/cairo-fallback-compositor.c \
    src/cairo-fixed.c \
    src/cairo-font-face-twin-data.c \
    src/cairo-font-face-twin.c \
    src/cairo-font-face.c \
    src/cairo-font-options.c \
    src/cairo-freed-pool.c \
    src/cairo-freelist.c \
    src/cairo-gstate.c \
    src/cairo-hash.c \
    src/cairo-hull.c \
    src/cairo-image-compositor.c \
    src/cairo-image-info.c \
    src/cairo-image-source.c \
    src/cairo-image-surface.c \
    src/cairo-line.c \
    src/cairo-lzw.c \
    src/cairo-mask-compositor.c \
    src/cairo-matrix.c \
    src/cairo-mempool.c \
    src/cairo-mesh-pattern-rasterizer.c \
    src/cairo-misc.c \
    src/cairo-mono-scan-converter.c \
    src/cairo-mutex.c \
    src/cairo-no-compositor.c \
    src/cairo-observer.c \
    src/cairo-output-stream.c \
    src/cairo-paginated-surface.c \
    src/cairo-path-bounds.c \
    src/cairo-path-fill.c \
    src/cairo-path-fixed.c \
    src/cairo-path-in-fill.c \
    src/cairo-path-stroke-boxes.c \
    src/cairo-path-stroke-polygon.c \
    src/cairo-path-stroke-traps.c \
    src/cairo-path-stroke-tristrip.c \
    src/cairo-path-stroke.c \
    src/cairo-path.c \
    src/cairo-pattern.c \
    src/cairo-pen.c \
    src/cairo-polygon-intersect.c \
    src/cairo-polygon-reduce.c \
    src/cairo-polygon.c \
    src/cairo-raster-source-pattern.c \
    src/cairo-recording-surface.c \
    src/cairo-rectangle.c \
    src/cairo-rectangular-scan-converter.c \
    src/cairo-region.c \
    src/cairo-rtree.c \
    src/cairo-scaled-font.c \
    src/cairo-shape-mask-compositor.c \
    src/cairo-slope.c \
    src/cairo-spans-compositor.c \
    src/cairo-spans.c \
    src/cairo-spline.c \
    src/cairo-stroke-dash.c \
    src/cairo-stroke-style.c \
    src/cairo-surface-clipper.c \
    src/cairo-surface-fallback.c \
    src/cairo-surface-observer.c \
    src/cairo-surface-offset.c \
    src/cairo-surface-snapshot.c \
    src/cairo-surface-subsurface.c \
    src/cairo-surface-wrapper.c \
    src/cairo-surface.c \
    src/cairo-time.c \
    src/cairo-tor-scan-converter.c \
    src/cairo-tor22-scan-converter.c \
    src/cairo-toy-font-face.c \
    src/cairo-traps-compositor.c \
    src/cairo-traps.c \
    src/cairo-tristrip.c \
    src/cairo-unicode.c \
    src/cairo-user-font.c \
    src/cairo-version.c \
    src/cairo-wideint.c \
    src/cairo.c \
    src/cairo-cff-subset.c \
    src/cairo-scaled-font-subsets.c \
    src/cairo-truetype-subset.c \
    src/cairo-type1-fallback.c \
    src/cairo-type1-glyph-names.c \
    src/cairo-type1-subset.c \
    src/cairo-type3-glyph-surface.c \
    src/cairo-pdf-operators.c \
    src/cairo-pdf-shading.c \
    src/cairo-tag-attributes.c \
    src/cairo-tag-stack.c \
    src/cairo-deflate-stream.c \
    src/cairo-png.c \
    src/cairo-ft-font.c \
    src/cairo-colr-glyph-render.c \
    src/cairo-svg-glyph-render.c
mkdir -p "$OUT/include/cairo"
cp src/cairo.h src/cairo-deprecated.h src/cairo-ft.h src/cairo-version.h "$HERE/config/cairo/cairo-features.h" "$OUT/include/cairo/"
