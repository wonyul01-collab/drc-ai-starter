# 매뉴얼을 깃허브 페이지(docs/index.html)로 만들고, 저장소 주인 이름을 모든 파일에 넣는다.
param([Parameter(Mandatory)][string]$Owner)
$root = Split-Path $PSScriptRoot -Parent
$utf8 = New-Object Text.UTF8Encoding $false
$bom  = New-Object Text.UTF8Encoding $true

# 1) 주인 이름 넣기
foreach ($f in 'install.ps1', 'README.md', 'manual\클로드_자동화_매뉴얼.html') {
  $p = Join-Path $root $f; $t = [IO.File]::ReadAllText($p, [Text.Encoding]::UTF8)
  $t = $t.Replace('__OWNER__', $Owner)
  [IO.File]::WriteAllText($p, $t, $(if ($f -like '*.ps1') { $bom } else { $utf8 }))
}

# 2) 깃허브 페이지용 완전한 HTML 문서로 감싸기
$body = [IO.File]::ReadAllText((Join-Path $root 'manual\클로드_자동화_매뉴얼.html'), [Text.Encoding]::UTF8)
$doc = "<!doctype html>`n<html lang=`"ko`">`n<head>`n<meta charset=`"utf-8`">`n<meta name=`"viewport`" content=`"width=device-width, initial-scale=1, viewport-fit=cover`">`n<style>[hidden]{display:none!important}</style>`n</head>`n<body>`n$body`n</body>`n</html>`n"
New-Item -ItemType Directory -Force (Join-Path $root 'docs') | Out-Null
[IO.File]::WriteAllText((Join-Path $root 'docs\index.html'), $doc, $utf8)
[IO.File]::WriteAllText((Join-Path $root 'docs\.nojekyll'), '', $utf8)
"완료: docs\index.html (주인 $Owner)"
