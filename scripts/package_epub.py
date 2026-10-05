"""Package TeX4ht XHTML output as a small EPUB 3 book."""

from __future__ import annotations

import argparse
import html
import re
import zipfile
from pathlib import Path


def heading_text(path: Path) -> str:
    if path.name == "main.html":
        return "目录"
    data = path.read_text(encoding="utf-8", errors="replace")
    match = re.search(r"<h[1-6][^>]*>(.*?)</h[1-6]>", data, re.I | re.S)
    if not match:
        return path.stem
    text = re.sub(r"<[^>]+>", "", match.group(1))
    return html.unescape(" ".join(text.split())) or path.stem


def package(source: Path, destination: Path, title: str) -> None:
    pages = sorted(source.glob("*.html"), key=lambda path: (path.name != "main.html", path.name))
    if not pages:
        raise SystemExit(f"no XHTML pages found in {source}")

    assets = sorted(
        path
        for path in source.iterdir()
        if path.is_file() and path.suffix.lower() in {".css", ".png", ".svg", ".jpg", ".jpeg", ".gif"}
    )
    destination.parent.mkdir(parents=True, exist_ok=True)
    if destination.exists():
        destination.unlink()

    nav_items = "\n".join(
        f'      <li><a href="{html.escape(page.name)}">{html.escape(heading_text(page))}</a></li>'
        for page in pages
    )
    nav = f"""<?xml version="1.0" encoding="utf-8"?>
<html xmlns="http://www.w3.org/1999/xhtml" xmlns:epub="http://www.idpf.org/2007/ops">
  <head><title>{html.escape(title)}</title></head>
  <body><nav epub:type="toc" id="toc"><h1>{html.escape(title)}</h1><ol>
{nav_items}
  </ol></nav></body>
</html>
"""

    manifest = [
        '    <item id="nav" href="nav.xhtml" media-type="application/xhtml+xml" properties="nav"/>',
    ]
    spine = []
    for index, page in enumerate(pages, 1):
        item_id = f"page{index}"
        manifest.append(
            f'    <item id="{item_id}" href="{html.escape(page.name)}" media-type="application/xhtml+xml"/>'
        )
        spine.append(f'    <itemref idref="{item_id}"/>')
    for index, asset in enumerate(assets, 1):
        suffix = asset.suffix.lower()
        media = {
            ".css": "text/css",
            ".png": "image/png",
            ".svg": "image/svg+xml",
            ".jpg": "image/jpeg",
            ".jpeg": "image/jpeg",
            ".gif": "image/gif",
        }[suffix]
        manifest.append(
            f'    <item id="asset{index}" href="{html.escape(asset.name)}" media-type="{media}"/>'
        )

    opf = f"""<?xml version="1.0" encoding="utf-8"?>
<package xmlns="http://www.idpf.org/2007/opf" version="3.0" unique-identifier="book-id">
  <metadata xmlns:dc="http://purl.org/dc/elements/1.1/">
    <dc:identifier id="book-id">urn:uuid:a4-chinese-book-template</dc:identifier>
    <dc:title>{html.escape(title)}</dc:title>
    <dc:language>zh-CN</dc:language>
    <meta property="dcterms:modified">2026-10-06T00:00:00Z</meta>
  </metadata>
  <manifest>
{chr(10).join(manifest)}
  </manifest>
  <spine>
{chr(10).join(spine)}
  </spine>
</package>
"""
    container = """<?xml version="1.0" encoding="utf-8"?>
<container version="1.0" xmlns="urn:oasis:names:tc:opendocument:xmlns:container">
  <rootfiles><rootfile full-path="OEBPS/content.opf" media-type="application/oebps-package+xml"/></rootfiles>
</container>
"""

    with zipfile.ZipFile(destination, "w") as archive:
        archive.writestr("mimetype", "application/epub+zip", compress_type=zipfile.ZIP_STORED)
        archive.writestr("META-INF/container.xml", container, compress_type=zipfile.ZIP_DEFLATED)
        archive.writestr("OEBPS/nav.xhtml", nav, compress_type=zipfile.ZIP_DEFLATED)
        archive.writestr("OEBPS/content.opf", opf, compress_type=zipfile.ZIP_DEFLATED)
        for page in pages:
            archive.write(page, f"OEBPS/{page.name}", compress_type=zipfile.ZIP_DEFLATED)
        for asset in assets:
            archive.write(asset, f"OEBPS/{asset.name}", compress_type=zipfile.ZIP_DEFLATED)


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("source", type=Path)
    parser.add_argument("destination", type=Path)
    parser.add_argument("--title", default="A4 中文书籍 LaTeX 模板")
    args = parser.parse_args()
    package(args.source, args.destination, args.title)


if __name__ == "__main__":
    main()
