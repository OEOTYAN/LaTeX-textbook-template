[CmdletBinding()]
param(
  [ValidateSet('pdf', 'html', 'epub')]
  [string]$Format = 'pdf',
  [ValidateSet('tectonic', 'xelatex')]
  [string]$Engine = 'tectonic',
  [string]$OutputDirectory = 'build'
)

$ErrorActionPreference = 'Stop'
$ProjectRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$BuildRoot = Join-Path $ProjectRoot $OutputDirectory

# 字体由模板随稿分发；缺文件时直接失败，避免引擎回退到系统字体。
$RequiredFonts = @(
  'fonts\NotoSerifSC-Regular.otf',
  'fonts\NotoSerifSC-Bold.otf',
  'fonts\NotoSansCJKsc-Regular.otf',
  'fonts\NotoSansCJKsc-Bold.otf',
  'fonts\NotoSansMonoCJKsc-Regular.otf',
  'fonts\NotoSansMonoCJKsc-Bold.otf',
  'fonts\STIXTwoMath-Regular.otf',
  'fonts\materialdesignicons-webfont.ttf'
)
foreach ($Font in $RequiredFonts) {
  $FontPath = Join-Path $ProjectRoot $Font
  if (-not (Test-Path -LiteralPath $FontPath -PathType Leaf)) {
    throw "缺少随稿字体文件：$Font"
  }
}

New-Item -ItemType Directory -Force -Path $BuildRoot | Out-Null
Push-Location $ProjectRoot
try {
  if ($Format -eq 'html' -or $Format -eq 'epub') {
    $Make4ht = Get-Command make4ht -ErrorAction SilentlyContinue
    if (-not $Make4ht) {
      throw '未找到 make4ht。请安装 TeX4ht，或在 GitHub Actions 中使用 texlive-plain-generic。'
    }
    $Python = Get-Command python -ErrorAction SilentlyContinue
    if (-not $Python) {
      $Python = Get-Command python3 -ErrorAction SilentlyContinue
    }
    if (-not $Python) {
      throw '未找到 python。EPUB 打包需要 Python 3。'
    }

    $WebRoot = Join-Path $BuildRoot $Format
    $WebWork = Join-Path $BuildRoot "$Format-work"
    New-Item -ItemType Directory -Force -Path $WebRoot,$WebWork | Out-Null
    & $Make4ht.Source '-x' '-c' 'tex4ht.cfg' '-B' $WebWork 'main.tex' 'xhtml,mathml'
    if ($LASTEXITCODE -ne 0) {
      throw "make4ht $Format 导出失败，退出码：$LASTEXITCODE"
    }

    Get-ChildItem -LiteralPath $WebWork -File |
      Where-Object { $_.Extension -in '.html', '.css', '.png', '.svg', '.jpg', '.jpeg', '.gif' } |
      Copy-Item -Destination $WebRoot -Force
    $WebCss = Join-Path $ProjectRoot 'web.css'
    $GeneratedCss = Join-Path $WebRoot 'main.css'
    if ((Test-Path -LiteralPath $WebCss) -and (Test-Path -LiteralPath $GeneratedCss)) {
      Add-Content -LiteralPath $GeneratedCss -Value (Get-Content -Raw -LiteralPath $WebCss) -Encoding utf8
    }

    if ($Format -eq 'epub') {
      $EpubPath = Join-Path $BuildRoot 'main.epub'
      & $Python.Source 'scripts/package_epub.py' $WebRoot $EpubPath '--title' 'A4 中文书籍 LaTeX 模板'
      if ($LASTEXITCODE -ne 0) {
        throw "EPUB 打包失败，退出码：$LASTEXITCODE"
      }
      Write-Host "EPUB 写入 $EpubPath"
    }
    else {
      Write-Host "HTML 写入 $WebRoot"
    }
  }
  elseif ($Engine -eq 'tectonic') {
    $Tool = Get-Command tectonic -ErrorAction SilentlyContinue
    if (-not $Tool) {
      throw '未找到 tectonic。请安装 Tectonic，或使用 -Engine xelatex。'
    }
    & $Tool.Source -X compile --outdir $BuildRoot --keep-logs --untrusted 'main.tex'
    if ($LASTEXITCODE -ne 0) {
      throw "Tectonic 编译失败，退出码：$LASTEXITCODE"
    }
  }
  else {
    $Tool = Get-Command xelatex -ErrorAction SilentlyContinue
    if (-not $Tool) {
      throw '未找到 xelatex。请安装 TeX Live 或 MiKTeX。'
    }
    # fullquote 的 side/full 选择依赖上一遍写入 aux 的页面和环绕记录；
    # 反复编译到这些记录稳定，避免交付 PDF 在两种排法之间抖动。
    $AuxPath = Join-Path $BuildRoot 'main.aux'
    $Previous = $null
    $Stable = $false
    for ($Pass = 1; $Pass -le 10; $Pass++) {
      & $Tool.Source '-interaction=nonstopmode' '-halt-on-error' '-file-line-error' "-output-directory=$BuildRoot" 'main.tex' | Out-Null
      if ($LASTEXITCODE -ne 0) {
        throw "XeLaTeX 第 $Pass 遍编译失败，退出码：$LASTEXITCODE"
      }
      $Current = ''
      if (Test-Path -LiteralPath $AuxPath) {
        $Current = (Select-String -LiteralPath $AuxPath -Pattern '\\fq@rec\{[0-9A-F]+\}\{(mode|lock|short)\}' | ForEach-Object { $_.Line }) -join "`n"
      }
      if ($Pass -ge 2 -and $Current -eq $Previous) {
        $Stable = $true
        break
      }
      $Previous = $Current
    }
    if (-not $Stable) {
      throw 'XeLaTeX 编译 10 遍后引文排法仍未稳定'
    }
    Write-Host "XeLaTeX 编译 $Pass 遍"
  }
}
finally {
  Pop-Location
}
