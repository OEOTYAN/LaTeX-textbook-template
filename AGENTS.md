# A4 中文书籍 LaTeX 模板：协作约定

## 范围

本目录是中文书籍版式母版和视觉校样。`chapters/sample.tex` 采用章、课层级来展示页面接口，这个层级属于样张配置，不限定正式书稿的目录结构。样张只验证页面结构，不能被当作正文或理论稿。正文接入前，先在独立分支完成文字审计，再替换样张内容。

## 源码职责

- `main.tex`：文档入口、封面、扉页、目录和示例章节装配。这里不放版式细节。
- `preamble.tex`：页面尺寸、字体、颜色、标题、栏目、图像、引文、表格和公式接口的唯一来源。
- `chapters/`：按章拆分正文；正式文件从 `main.tex` 用 `\input` 接入。
- `styles/`：网格规格、页面母版、平面计划和审美检查表。
- `fonts/`：随稿件分发的 Material Design Icons 字体；许可说明在 `licenses/`。
- `.github/workflows/build.yml`：GitHub Actions 的 XeLaTeX 构建和 PDF artifact 上传。
- `template-preview.pdf`：最近一次人工校样的可视预览，可以提交；编译中间文件不能提交。
- `assets/preview-spread.png` 和 `assets/preview-material-page.png`：从最近一次 PDF 直接渲染的 README 展示图，更新预览时同步替换。

## 字体

Tectonic 和 GitHub Actions 的 TeX Live 构建使用 CTeX Fandol 字体集：`FandolSong-Regular`，粗体为 `FandolSong-Bold`，斜体为 `FandolKai-Regular`，无衬线为 `FandolHei`。Windows MiKTeX 未安装 Fandol 时会使用 SimSun 作为系统替代；校样时应记录所用发行版。拉丁正文使用 Latin Modern Roman，数学沿 Computer Modern 数学字形。Material Design Icons 是单独的本地字体，只用于栏目图标，不作为正文字体。

## 版式接口

- 样张用 `\chapter{...}`、`\section{...}`、`\subsection{...}` 展示三级标题；正式稿可以将它们映射为部分、章、节等层级。
- `\sidequote[位置][宽度]{作者}{作品、版本、页码}{原文}` 必须从段首调用；段落结束用 `\bookwrapclear` 收束环绕状态。
- `fullquote` 用于宽幅引文，作者、作品和版本信息放在同一条出处行。
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

没有全局 `tectonic` 时，使用本机 LaTeX 发行版或项目提供的 `build.ps1`。正式提交前至少完成：

1. 编译两遍或使用会自动重跑目录的构建器。
2. 用 Poppler 渲染封面、目录、章首页、课首页、侧边引文、宽幅引文、表格和公式页。
3. 检查标题基线、目录引导线、折角几何、表格留白、公式编号和页码外侧定位。
4. 用 `git diff --check` 检查空白和冲突标记。

## 修改纪律

- 只修改与当前版式或正文任务直接相关的文件，不把 `work/`、日志或临时截图加入提交。
- 改动接口时同步更新 `README.md`、相关 `styles/*.md` 和本文件。
- 保留 `fonts/` 与 `licenses/` 的来源和许可说明。
- 推送前查看 `git status -sb`、`git diff --stat` 和最终 PDF 页数；不要静默覆盖无关文件。
