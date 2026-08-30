# A4 中文书籍 LaTeX 模板

[![Build textbook PDF](https://github.com/OEOTYAN/LaTeX-textbook-template/actions/workflows/build.yml/badge.svg)](https://github.com/OEOTYAN/LaTeX-textbook-template/actions/workflows/build.yml)

这是一个可直接编译的中文 A4 双面书籍母版。它把封面、目录、正文、材料栏、侧边图像、引文、表格和数学公式放在同一套网格里；`chapters/sample.tex` 使用章、课层级展示页面接口，这只是校样示例，正式项目可以改成部分、章、节或其他层级。

![实际编译结果：封面、目录、课页和材料页](assets/preview-spread.png)

上图由当前 `main.tex` 编译后的 PDF 直接渲染。

## 快速开始

在仓库根目录执行：

```powershell
.\build.ps1
```

脚本默认调用本机 `tectonic`，输出写入 `build/`。已有 TeX Live 时可以执行：

```powershell
.\build.ps1 -Engine xelatex
```

也可以直接运行 `tectonic -X compile --outdir build main.tex`。目录需要更新时，Tectonic 会自动重跑；XeLaTeX 模式由脚本运行两遍。

## 目录结构

```text
main.tex                       文档入口与前置页
preamble.tex                   版式和全部可复用接口
chapters/sample.tex            视觉校样章节
styles/                        网格、母版、平面计划、审美检查
fonts/                         Material Design Icons 字体资源
licenses/                      字体许可与归属说明
.github/workflows/build.yml    GitHub Actions 自动构建
AGENTS.md                      协作和校样约定
template-preview.pdf           最近一次人工校样
```

## 示例层级接口

- `\chapter{...}`：当前校样的第一层标题，35 × 27 mm 编号块，34 pt 黑色重标题。
- `\section{...}`：当前校样的第二层标题，20 × 12 mm 浅蓝编号块，20 pt 蓝色标题；两位数编号也有预留宽度。
- `\subsection{...}`：当前校样的第三层标题，14 pt 蓝色标题。
- 正文：中文小四，1.20 倍行距，首行缩进 2em，双面内外侧边距由 `geometry` 统一管理。

## 栏目接口

问题栏目默认使用 `head-question-outline`。按语境替换时，`preamble.tex` 提供 `\mdiChatQuestion`、`\mdiLightbulbQuestion`、`\mdiFileQuestion`、`\mdiTableQuestion`、`\mdiBeakerQuestion`、`\mdiFolderQuestion`、`\mdiCommentQuestion` 和 `\mdiMessageQuestion`。

### 小引文

小引文从段首调用，正文沿便利贴的实际高度环绕：

```latex
\sidequote[r][0.24\linewidth]{作者}{作品、版本、页码}{经过版本核对的原文。}
这里接着写正文，文字会在便利贴旁边排版。
\bookwrapclear
```

`\bookwrapclear` 在进入下一个标题或栏目之前收束环绕状态。章节内容不要用临时 `\clearpage` 来隔离引文。

### 大引文

```latex
\begin{fullquote}{作者}{作品、版本、页码}
这里放需要在版心中完整阅读的原文。
\end{fullquote}
```

作者、作品和版本信息位于同一条出处行，折角为固定 5 mm 的纸面标记。

### 图像与表格

侧边材料使用 `\sideplaceholder` 或 `\sideimage`，全宽材料使用 `\fullplaceholder` 或 `\fullimage`。图像保持原比例，图注登记对象和来源。

表格使用 `booktable`，表题使用 `\tablecaption{...}`：

```latex
\tablecaption{表 1　页面元素与版式职责}
\begin{booktable}{@{}p{27mm}X@{}}
  ...
\end{booktable}
```

### 数学

行内公式写作 `$...$`，不改变中文正文的基线行距。`$$...$$` 会进入 TeX 的陈列公式模式，公式独占一行；无编号陈列使用 `\[...\]` 或 `equation*`，带编号的行间公式使用 `equation`，多行推导使用 `align`。编号按章递增，形式为 `(章.序号)`，交叉引用使用 `\label` 和 `\eqref`。

## 字体与许可

在 Tectonic 和 GitHub Actions 的 TeX Live 环境中，中文正文使用 CTeX Fandol 字体集：`FandolSong-Regular`、`FandolSong-Bold`、`FandolKai-Regular` 和 `FandolHei`。Windows MiKTeX 若未安装 Fandol，会按其系统字体集选择 SimSun；这只影响本地替代字体，不改变版心和字号规则。拉丁正文是 Latin Modern Roman，数学使用 Computer Modern 数学字形。栏目图标使用 `fonts/materialdesignicons-webfont.ttf`，归属和 Apache License 2.0 说明见 `fonts/README.md` 与 `licenses/`。

## 页面细节预览

![材料页实际编译结果](assets/preview-material-page.png)

## 自动构建

`.github/workflows/build.yml` 在 `main` 的 push、Pull Request 和手动触发时运行 XeLaTeX，构建完成后上传 `main.pdf` artifact。工作流使用完整 TeX Live 环境，仓库内的图标字体随源码一起加载。

## 校样顺序

1. 编译并确认目录和交叉引用已更新。
2. 渲染封面、目录、章首页、课首页、引文页、表格页和公式页。
3. 检查标题基线、目录编号栏、引导线、折角、表格上下留白和外侧页码。
4. 运行 `git diff --check`，确认提交中没有日志、临时图片和 `build/` 文件。

正式书名、作者、出版社和章节正文仍是待替换字段；模板不预设理论内容。
