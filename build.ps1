[CmdletBinding()]
param(
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
  if ($Engine -eq 'tectonic') {
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
    & $Tool.Source '-interaction=nonstopmode' '-halt-on-error' '-file-line-error' "-output-directory=$BuildRoot" 'main.tex'
    if ($LASTEXITCODE -ne 0) {
      throw "XeLaTeX 第一次编译失败，退出码：$LASTEXITCODE"
    }
    & $Tool.Source '-interaction=nonstopmode' '-halt-on-error' '-file-line-error' "-output-directory=$BuildRoot" 'main.tex'
    if ($LASTEXITCODE -ne 0) {
      throw "XeLaTeX 第二次编译失败，退出码：$LASTEXITCODE"
    }
  }
}
finally {
  Pop-Location
}
