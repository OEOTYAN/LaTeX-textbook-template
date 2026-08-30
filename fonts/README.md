# 随稿字体

正文使用仓库内的 Noto CJK 静态 OpenType 文件；等宽文字另用 Noto Sans Mono CJK。所有文件保持上游名称、版本和字形内容。

| 文件 | 字体 | 版本 | 用途 |
| --- | --- | --- | --- |
| `NotoSerifSC-Regular.otf` | Noto Serif SC | 2.003 | 正文常规 |
| `NotoSerifSC-Bold.otf` | Noto Serif SC | 2.003 | 正文粗体 |
| `NotoSansCJKsc-Regular.otf` | Noto Sans CJK SC | 2.004 | 无衬线正文与栏目 |
| `NotoSansCJKsc-Bold.otf` | Noto Sans CJK SC | 2.004 | 无衬线粗体 |
| `NotoSansMonoCJKsc-Regular.otf` | Noto Sans Mono CJK SC | 2.004 | 等宽文字常规 |
| `NotoSansMonoCJKsc-Bold.otf` | Noto Sans Mono CJK SC | 2.004 | 等宽文字粗体 |
| `STIXTwoMath-Regular.otf` | STIX Two Math | 2.13 b171 | Unicode 数学 |

Noto 字体来源是 [notofonts/noto-cjk](https://github.com/notofonts/noto-cjk) 的官方发布包 `14_NotoSerifSC.zip`、`08_NotoSansCJKsc.zip` 和 `13_NotoSansMonoCJKsc.zip`；STIX Two Math 来源是 [stipub/stixfonts](https://github.com/stipub/stixfonts) 的 `v2.13b171` 发布包。Noto 与 STIX Two Math 均以 SIL Open Font License 1.1 发布；完整许可证分别在 `licenses/OFL-1.1-Noto-CJK.txt` 和 `licenses/OFL-1.1-STIX-Two.txt`，归属和版本记录在 `licenses/Noto-CJK-ATTRIBUTION.txt` 与 `licenses/STIX-Two-ATTRIBUTION.txt`。文件校验值在 `SHA256SUMS.txt`。

`preamble.tex` 使用 `fontset=none` 配合相对路径显式载入这些文件，并为宋体、黑体、仿宋、楷体和等宽接口设置固定映射。因此字体选择不随 Windows、Linux 或 macOS 变化。相同字体文件固定了字形和度量；要得到逐页完全相同的 PDF，还应使用同一 XeTeX/Tectonic 版本和同一套 LaTeX 包，仓库的 Actions 已固定 TeX Live 2025。

图标字体 `materialdesignicons-webfont.ttf` 是独立资源，来源和 Apache License 2.0 说明见 `licenses/MaterialDesign-Webfont-NOTICE.txt`；它只参与栏目图标。
