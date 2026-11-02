# =====================================================================
#  디알컴퍼니 클로드 자동화 개발 키트 - 한 번에 설치
#  사용법 1) 인터넷에서 바로:  irm https://raw.githubusercontent.com/wonyul01-collab/drc-ai-starter/main/install.ps1 | iex
#  사용법 2) 내려받은 폴더에서: 설치.bat 더블클릭
#  점검만:   install.ps1 -OnlyCheck
#  이미 설치된 프로그램은 건너뜁니다. 여러 번 실행해도 안전합니다.
# =====================================================================
param([switch]$OnlyCheck)

$ErrorActionPreference = 'Continue'
$Owner   = 'wonyul01-collab'                     # 깃허브 저장소 주인(회사 계정)
$RepoZip = "https://github.com/$Owner/drc-ai-starter/archive/refs/heads/main.zip"
$Work    = Join-Path $env:USERPROFILE '클로드작업'
$Log     = Join-Path $env:TEMP ("drc_install_" + (Get-Date -Format 'yyyyMMdd_HHmmss') + '.log')
[Console]::OutputEncoding = [Text.Encoding]::UTF8

function Say($t, $c = 'White') { Write-Host $t -ForegroundColor $c; Add-Content $Log $t -Encoding utf8 }
function Refresh-Path {
  $m = [Environment]::GetEnvironmentVariable('Path', 'Machine'); $u = [Environment]::GetEnvironmentVariable('Path', 'User')
  $env:Path = "$m;$u;$env:USERPROFILE\.local\bin;$env:APPDATA\npm"
}
function Has($cmd) { [bool](Get-Command $cmd -ErrorAction SilentlyContinue) }
function Installed($id) { winget list --id $id -e --accept-source-agreements *> $null; return ($LASTEXITCODE -eq 0) }

# 설치 목록: 이름, 확인 명령(또는 경로), winget 이름, 하는 일
$Apps = @(
  @{n='Git';                c='git';    id='Git.Git';                    why='작업 저장점(되돌리기), 깃허브 연결'},
  @{n='Node.js';            c='node';   id='OpenJS.NodeJS.LTS';          why='화면 게시(Vercel), 리모션·HyperFrames 영상'},
  @{n='Python 3.14';        c='python'; id='Python.Python.3.14';         why='자료 수집·계산·엑셀 만들기'},
  @{n='VS Code';            c='code';   id='Microsoft.VisualStudioCode'; why='만든 파일 열어 보기'},
  @{n='FFmpeg';             c='ffmpeg'; id='Gyan.FFmpeg';                why='영상·소리 변환'},
  @{n='Claude 데스크톱 앱'; p="$env:LOCALAPPDATA\AnthropicClaude"; id='Anthropic.Claude'; why='창에서 클로드 쓰기(코드 탭)'},
  @{n='옵시디언';           p="$env:LOCALAPPDATA\Programs\Obsidian"; id='Obsidian.Obsidian'; why='작업 기록·회사 지식 보관'},
  @{n='크롬';               p="${env:ProgramFiles}\Google\Chrome\Application\chrome.exe"; id='Google.Chrome'; why='Claude in Chrome 확장, 사이트 자동 조작'}
)

function Show-Status {
  Refresh-Path
  Say "`n──── 설치 점검 결과 ────" Cyan
  $miss = 0
  foreach ($a in $Apps) {
    $ok = if ($a.c) { Has $a.c } else { (Test-Path $a.p) -or (Installed $a.id) }
    if ($ok) { Say ("  [설치됨]  " + $a.n) Green } else { Say ("  [없음]    " + $a.n + "  → winget install --id " + $a.id) Yellow; $miss++ }
  }
  foreach ($x in @(@{n='GitHub CLI';c='gh'}, @{n='Claude Code';c='claude'}, @{n='Vercel CLI';c='vercel'})) {
    if (Has $x.c) { Say ("  [설치됨]  " + $x.n) Green } else { Say ("  [없음]    " + $x.n) Yellow; $miss++ }
  }
  $font = Get-ChildItem "$env:LOCALAPPDATA\Microsoft\Windows\Fonts", "$env:WINDIR\Fonts" -Filter 'Pretendard*' -ErrorAction SilentlyContinue
  if ($font) { Say "  [설치됨]  Pretendard 글꼴" Green } else { Say "  [없음]    Pretendard 글꼴" Yellow; $miss++ }
  if (Has 'python') { $py = python -c "import pandas, openpyxl, fastapi, playwright; print('ok')" 2>$null
    if ($py -eq 'ok') { Say "  [설치됨]  파이썬 도구 묶음" Green } else { Say "  [없음]    파이썬 도구 묶음" Yellow; $miss++ } }
  if (Test-Path (Join-Path $Work 'CLAUDE.md')) { Say "  [설치됨]  작업 폴더·회사 규칙 ($Work)" Green } else { Say "  [없음]    작업 폴더·회사 규칙" Yellow; $miss++ }
  return $miss
}

if ($OnlyCheck) { $m = Show-Status; Say "`n빠진 것: $m 개" Cyan; return }

Say "==============================================" Cyan
Say "  디알컴퍼니 클로드 자동화 개발 키트 설치 시작" Cyan
Say "  창을 닫지 마세요. 10~25분 걸립니다." Cyan
Say "  중간에 '변경을 허용하시겠습니까?' 창이 뜨면 [예]를 누르세요." Cyan
Say "==============================================" Cyan

if (-not (Has 'winget')) {
  Say "winget(윈도우 앱 설치 도구)이 없습니다. Microsoft Store에서 '앱 설치 관리자'를 업데이트한 뒤 다시 실행하세요." Red
  Start-Process 'ms-windows-store://pdp/?ProductId=9NBLGGH4NNS1'; return
}

$total = $Apps.Count + 6; $i = 0
foreach ($a in $Apps) {
  $i++; Refresh-Path
  $ok = if ($a.c) { Has $a.c } else { (Test-Path $a.p) -or (Installed $a.id) }
  if ($ok) { Say "[$i/$total] $($a.n) - 이미 있음, 건너뜀" DarkGray; continue }
  Say "[$i/$total] $($a.n) 설치 중 … ($($a.why))" White
  winget install --id $a.id -e --silent --accept-package-agreements --accept-source-agreements --disable-interactivity *>> $Log
  if ($LASTEXITCODE -eq 0) { Say "        완료" Green } else { Say "        실패(코드 $LASTEXITCODE) - 끝난 뒤 점검 결과를 보세요" Yellow }
}
Refresh-Path

# GitHub CLI (관리자 권한 창 없이 사용자 폴더에 설치 - winget 판은 권한 창에서 멈춘 이력)
$i++
if (Has 'gh') { Say "[$i/$total] GitHub CLI - 이미 있음, 건너뜀" DarkGray }
else {
  Say "[$i/$total] GitHub CLI 설치 중 … (깃허브 로그인·저장소 만들기)" White
  try {
    $gd = "$env:LOCALAPPDATA\Programs\gh"; $gz = Join-Path $env:TEMP 'gh_portable.zip'
    $rel = Invoke-RestMethod 'https://api.github.com/repos/cli/cli/releases/latest' -UseBasicParsing
    $url = ($rel.assets | Where-Object { $_.name -like '*_windows_amd64.zip' } | Select-Object -First 1).browser_download_url
    Invoke-WebRequest $url -OutFile $gz -UseBasicParsing; Expand-Archive $gz $gd -Force
    $up = [Environment]::GetEnvironmentVariable('Path', 'User')
    if ($up -notlike "*$gd\bin*") { [Environment]::SetEnvironmentVariable('Path', "$up;$gd\bin", 'User') }
    Say "        완료" Green
  } catch { Say "        실패: $($_.Exception.Message)" Yellow }
}
Refresh-Path

# Claude Code (공식 설치 명령)
$i++
if (Has 'claude') { Say "[$i/$total] Claude Code - 이미 있음, 건너뜀" DarkGray }
else {
  Say "[$i/$total] Claude Code 설치 중 … (터미널에서 말로 시키는 클로드)" White
  try { Invoke-RestMethod https://claude.ai/install.ps1 | Invoke-Expression *>> $Log; Say "        완료" Green } catch { Say "        실패: $($_.Exception.Message)" Yellow }
}
Refresh-Path

# Vercel CLI (회사 기준 65.0.0 고정 - 최신판 설치 오류 이력 있음)
$i++
if (Has 'vercel') { Say "[$i/$total] Vercel CLI - 이미 있음, 건너뜀" DarkGray }
elseif (Has 'npm') { Say "[$i/$total] Vercel CLI 설치 중 … (만든 화면을 인터넷 주소로 게시)" White; npm install -g vercel@65.0.0 *>> $Log; Say "        완료" Green }
else { Say "[$i/$total] Vercel CLI - Node.js가 없어 건너뜀" Yellow }

# 파이썬 도구 묶음
$i++
if (Has 'python') {
  Say "[$i/$total] 파이썬 도구 묶음 설치 중 … (엑셀·화면 서버·사이트 자동 조작)" White
  python -m pip install --upgrade pip *>> $Log
  python -m pip install pandas openpyxl xlsxwriter requests python-dotenv fastapi uvicorn pyinstaller pywin32 "playwright==1.60.0" *>> $Log
  python -m playwright install chromium *>> $Log
  Say "        완료" Green
} else { Say "[$i/$total] 파이썬 도구 - Python이 없어 건너뜀(창을 닫고 다시 실행하면 이어서 설치)" Yellow }

# Pretendard 글꼴 (회사 문서·화면·영상 기본 글꼴)
$i++
$fontDir = "$env:LOCALAPPDATA\Microsoft\Windows\Fonts"
if (Get-ChildItem $fontDir, "$env:WINDIR\Fonts" -Filter 'Pretendard*' -ErrorAction SilentlyContinue) { Say "[$i/$total] Pretendard 글꼴 - 이미 있음, 건너뜀" DarkGray }
else {
  Say "[$i/$total] Pretendard 글꼴 설치 중 …" White
  try {
    $zip = Join-Path $env:TEMP 'pretendard.zip'; $dst = Join-Path $env:TEMP 'pretendard_x'
    Invoke-WebRequest 'https://github.com/orioncactus/pretendard/releases/download/v1.3.9/Pretendard-1.3.9.zip' -OutFile $zip -UseBasicParsing
    Expand-Archive $zip $dst -Force
    New-Item -ItemType Directory -Force $fontDir | Out-Null
    $reg = 'HKCU:\Software\Microsoft\Windows NT\CurrentVersion\Fonts'
    Get-ChildItem $dst -Recurse -Filter 'Pretendard-*.otf' | Where-Object { $_.FullName -notmatch 'Variable|JP|Std' } | ForEach-Object {
      Copy-Item $_.FullName $fontDir -Force
      New-ItemProperty -Path $reg -Name ($_.BaseName + ' (OpenType)') -Value (Join-Path $fontDir $_.Name) -PropertyType String -Force | Out-Null
    }
    Say "        완료" Green
  } catch { Say "        실패: $($_.Exception.Message)" Yellow }
}

# 작업 폴더 + 회사 규칙 + 회사 스킬
$i++
Say "[$i/$total] 작업 폴더와 회사 규칙 깔기 … ($Work)" White
$src = $null
$here = if ($PSScriptRoot) { $PSScriptRoot } elseif ($env:DRC_KIT_DIR) { $env:DRC_KIT_DIR.TrimEnd('\') } else { $null }
if ($here -and (Test-Path (Join-Path $here 'starter'))) { $src = $here }
else {
  try {
    $z = Join-Path $env:TEMP 'drc_starter.zip'; $x = Join-Path $env:TEMP 'drc_starter_x'
    Invoke-WebRequest $RepoZip -OutFile $z -UseBasicParsing; Expand-Archive $z $x -Force
    $src = (Get-ChildItem $x -Directory | Select-Object -First 1).FullName
  } catch { Say "        키트 내려받기 실패: $($_.Exception.Message)" Yellow }
}
if ($src) {
  New-Item -ItemType Directory -Force $Work, "$Work\내_자동화", "$env:USERPROFILE\.claude\skills" | Out-Null
  foreach ($f in 'CLAUDE.md', '.gitignore', '.env.example', '시작하기.md') {
    $t = Join-Path $Work $f
    if (Test-Path $t) { Say "        $f 는 이미 있어 그대로 둠" DarkGray } else { Copy-Item (Join-Path $src "starter\$f") $t }
  }
  Copy-Item (Join-Path $src 'skills\*') "$env:USERPROFILE\.claude\skills" -Recurse -Force
  Say "        완료 (회사 스킬: 자동화개발, 화면기준)" Green
}

$m = Show-Status
Say "`n==============================================" Cyan
if ($m -eq 0) { Say "  설치 끝! 빠진 것 없음." Green } else { Say "  설치 끝. 빠진 것 $m 개 - 컴퓨터를 다시 켠 뒤 같은 명령을 한 번 더 실행하세요." Yellow }
Say "  다음 할 일:" Cyan
Say "   1) 이 창을 닫고 새 PowerShell 창을 엽니다." Cyan
Say "   2) cd ~\클로드작업   입력 후 Enter" Cyan
Say "   3) claude   입력 후 Enter → 회사 계정으로 로그인" Cyan
Say "   4) gh auth login   (깃허브 로그인, 처음 한 번)" Cyan
Say "  설치 기록: $Log" DarkGray
Say "==============================================" Cyan
