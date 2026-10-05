# A4 中文书籍 LaTeX 模板：协作约定

## 范围

本目录是中文书籍版式母版和视觉校样。`chapters/sample.tex` 采用章、课层级来展示页面接口，这个层级属于样张配置，不限定正式书稿的目录结构。样张只验证页面结构，不能被当作正文或理论稿。正文接入前，先在独立分支完成文字审计，再替换样张内容。

## 源码职责

- `main.tex`：文档入口、封面、扉页、目录和示例章节装配。这里不放版式细节。
- `preamble.tex`：页面尺寸、字体、颜色、标题、栏目、图像、引文、表格和公式接口的唯一来源。
- `chapters/`：按章拆分正文，`frontmatter/` 放前言等前置正文；正式文件从 `main.tex` 用 `\input` 接入。
- `styles/`：网格规格、页面母版、平面计划和审美检查表。
- `fonts/`：随稿件分发的 Noto CJK 正文字体和 Material Design Icons；许可说明在 `licenses/`，校验值在 `fonts/SHA256SUMS.txt`。
- `.github/workflows/build.yml`：GitHub Actions 的 PDF、HTML 和 EPUB 构建与 artifact 上传。
- `scripts/package_epub.py`：把按节拆分的 XHTML 页面打包成 EPUB 3；`tex4ht.cfg` 控制 HTML/EPUB 的节页切分。
- `web.css`：HTML/EPUB 的流式阅读样式，不参与 PDF 页面版式。
- `template-preview.pdf`：最近一次人工校样的可视预览，可以提交；编译中间文件不能提交。
- `assets/preview-spread.png` 和 `assets/preview-material-page.png`：从最近一次 PDF 直接渲染的 README 展示图，更新预览时同步替换。

## 字体

正文固定使用 `fonts/` 中的 Noto Serif SC 2.003（常规、粗体）和 Noto Sans CJK SC 2.004（常规、粗体），等宽文字使用 Noto Sans Mono CJK SC 2.004；数学固定使用 STIX Two Math 2.13 b171。四组字体文件按 SIL Open Font License 1.1 原样分发，版本、来源和归属见 `licenses/Noto-CJK-ATTRIBUTION.txt` 与 `licenses/STIX-Two-ATTRIBUTION.txt`，许可证全文分别见 `licenses/OFL-1.1-Noto-CJK.txt` 与 `licenses/OFL-1.1-STIX-Two.txt`。

`main.tex` 使用 `fontset=none`；`preamble.tex` 显式设置 CJK 主字体、无衬线字体、Noto Sans Mono 等宽字体以及 `\songti`、`\heiti`、`\fangsong`、`\kaishu` 等接口，并用 `unicode-math` 加载仓库内的 STIX Two Math。字体搜索路径固定为 `fonts/`，排版不调用操作系统字体或发行版默认 fontset。Material Design Icons 是独立的 Apache License 2.0 图标资源，只用于栏目图标。

字体文件相同即可固定字形和度量；逐页完全一致还需要相同的 XeTeX/Tectonic 版本与 LaTeX 包版本。GitHub Actions 固定使用 TeX Live 2025，发布校样以该构建为准。

## 版式接口

- 样张用 `\chapter{...}`、`\section{...}`、`\subsection{...}` 展示三级标题；正式稿可以将它们映射为部分、章、节等层级。
- `\sidequote[位置][宽度]{作者}{作品、版本、页码}{原文}` 必须从段首调用；段落结束用 `\bookwrapclear` 收束环绕状态。正文引文优先使用 `fullquote`，它根据上一遍编译记录自动选择贴外侧或宽幅排法。
- `fullquote` 的 side 宽度为版心 40%，超过高度阈值、放不下本页、会压脚注或后文不足以环绕时转为 90% 版心的 full；作者、作品和版本信息放在同一条出处行，宽幅引文可以跨页，折角只落在最后一段。
- 正文出处使用 `\sourcecite{完整出处}`，默认进入脚注；`\sourcecitesinline` 可切换为文中括注，`\sourceciteagain{出处}` 复用紧邻的上一个脚注号。
- `\bookforeword` 生成前言标题、目录登记和前言页样式，正文放在 `chapters/frontmatter/foreword.tex`。
- `\sideplaceholder`、`\sideimage` 用于侧边图像；`\fullplaceholder`、`\fullimage` 用于全宽图像。图像保持原比例，图注登记对象和来源。
- `booktable` 统一表格上下留白；表题用 `\tablecaption{...}`。
- 行内公式写作 `$...$`；`$$...$$` 是陈列公式原语，会独占一行。无编号陈列使用 `\[...\]` 或 `equation*`，带编号公式使用 `equation`，多行推导使用 `align`。编号按章递增，引用用 `\label` 和 `\eqref`。

## 分页规则

章节内容不添加为了“测试”而存在的 `\clearpage`。目录宏内部的分页属于结构规则；扉页、目录和正文之间的分页只在确有页面职责时保留。侧边图像或引文结束前，先用对应的清理接口，不能直接改写 `\linewidth`、`\hsize` 或 `\parshape`。

## 编译与校样

本地优先使用 XeLaTeX 或 Tectonic：

```powershell
tectonic -X compile --outdir build main.tex
```

没有全局 `tectonic` 时，使用本机 LaTeX 发行版或项目提供的 `build.ps1`。`-Format html` 和 `-Format epub` 使用 TeX4ht，把每个 `section` 输出为独立 XHTML 页面；网页不按 PDF 的 A4 页硬分页，引文块跟随所在节。正式提交前至少完成：

1. 编译到目录、交叉引用和 `fullquote` 的 side/full 记录稳定；使用 `build.ps1` 时 XeLaTeX 最多重编十遍并在未稳定时失败。
2. 用 Poppler 渲染封面、目录、章首页、课首页、侧边引文、宽幅引文、表格和公式页。
3. 检查标题基线、目录引导线、折角几何、表格留白、公式编号和页码外侧定位。
4. 用 `git diff --check` 检查空白和冲突标记。

## 修改纪律

- 只修改与当前版式或正文任务直接相关的文件，不把 `work/`、日志或临时截图加入提交。
- 改动接口时同步更新 `README.md`、相关 `styles/*.md` 和本文件。
- 保留 `fonts/` 与 `licenses/` 的来源、许可说明和 `fonts/SHA256SUMS.txt`；替换字体时必须同步更新版本、归属和校验值。
- 推送前查看 `git status -sb`、`git diff --stat` 和最终 PDF 页数；不要静默覆盖无关文件。
