/* openamigacairo smoke test: shapes, a gradient and FreeType text into an
 * image surface, saved as PNG, with a checksum of the pixels. */
#include <stdio.h>
#include <stdint.h>
#include <cairo.h>
#include <cairo-ft.h>
#include <ft2build.h>
#include FT_FREETYPE_H
/* ROM mathieeesingbas.library leaves the FPU in single precision (FPCR $40)
 * in every task that opens it; doubles need FPCR 0. */
static void resetFPCR(void) { __asm__ volatile ("fmove.l %0,%%fpcr" : : "d" (0)); }

int main(int argc, char **argv)
{
    resetFPCR();
    cairo_surface_t *s = cairo_image_surface_create(CAIRO_FORMAT_ARGB32, 240, 120);
    cairo_t *cr = cairo_create(s); cairo_pattern_t *g; FT_Library ft; FT_Face face;
    uint32_t sum = 0; int x, y, stride; unsigned char *data;
    cairo_set_source_rgb(cr, 1, 1, 1); cairo_paint(cr);
    g = cairo_pattern_create_linear(0, 0, 240, 0);
    cairo_pattern_add_color_stop_rgb(g, 0, 0.2, 0.4, 0.9); cairo_pattern_add_color_stop_rgb(g, 1, 0.9, 0.3, 0.2);
    cairo_rectangle(cr, 10, 10, 220, 40); cairo_set_source(cr, g); cairo_fill(cr);
    cairo_arc(cr, 60, 85, 25, 0, 6.2831853); cairo_set_source_rgba(cr, 0, 0.6, 0, 0.7); cairo_fill(cr);
    if (argc > 1 && !FT_Init_FreeType(&ft) && !FT_New_Face(ft, argv[1], 0, &face)) {
        cairo_font_face_t *ff = cairo_ft_font_face_create_for_ft_face(face, 0);
        cairo_set_font_face(cr, ff); cairo_set_font_size(cr, 22);
        cairo_move_to(cr, 95, 95); cairo_set_source_rgb(cr, 0, 0, 0); cairo_show_text(cr, "Amiga");
    }
    cairo_surface_flush(s);
    data = cairo_image_surface_get_data(s); stride = cairo_image_surface_get_stride(s);
    for (y = 0; y < 120; y++) for (x = 0; x < 240; x++) sum = sum * 31 + *(uint32_t *)(data + y * stride + x * 4);
    printf("CAIRO %s status=%s sum=%08lx px(20,20)=%08lx px(60,85)=%08lx\n", cairo_version_string(), cairo_status_to_string(cairo_status(cr)),
           (unsigned long)sum, (unsigned long)*(uint32_t *)(data + 20 * stride + 20 * 4), (unsigned long)*(uint32_t *)(data + 85 * stride + 60 * 4));
    printf("PNG %s\n", cairo_status_to_string(cairo_surface_write_to_png(s, argc > 2 ? argv[2] : "T:openamigacairo-test.png")));
    cairo_destroy(cr); cairo_surface_destroy(s);
    return 0;
}
