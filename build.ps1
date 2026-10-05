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
