# Taste audit for the A4 book template

## Design read

Reading this as: an A4 educational book for sustained reading, with an editorial reference-textbook language, leaning toward an asymmetric print grid with restrained color.

## Dials

- `DESIGN_VARIANCE: 6`：左右页镜像，章页允许图像锚点和不对称留白。
- `MOTION_INTENSITY: 1`：纸面没有动画，变化由页型和材料节奏承担。
- `VISUAL_DENSITY: 6`：正文保持连续密度，栏目和图像只在有对象时出现。

## Applied rules

- One primary blue, one orange accent, and low-saturation semantic tints.
- One sharp-corner system for text blocks; the folded quote note is the documented exception.
- The body paragraph owns the page. A box appears only for a question, a source record, or a direct quotation.
- Side images and side quotations occupy a fixed fraction of the measure and let the body copy flow around their natural height.
- A long image or quotation uses the full-width interface. Neither interface crops content.
- Titles, labels, tables, captions, and body copy use a measured type scale rather than a single default size.
- Chapter and lesson markers keep the same rectangular language but differ in fill, footprint, title size, color, and spacing: chapter `35×27mm` with a black heavy `34pt` title; lesson `20×12mm` with a blue regular `20pt` title.

## Preflight

- Cover title and metadata sit in one non-overlapping text box.
- Chapter and lesson number blocks share a vertical center with their titles.
- Table labels never exceed body size.
- The table of contents uses fixed label columns and one page-number column.
- `relatedlink` styles are locally scoped and cannot leak into following paragraphs.
- Direct quotations use `fullquote`, which selects an outer side box or a centered full block from the previous compile record; manual `sidequote` remains available for fixed placement. `bookwrapclear` closes a short quote before the next heading, and no automatic explanatory paragraph is appended.
