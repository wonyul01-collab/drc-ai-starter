# 디알컴퍼니 클로드 자동화 개발 키트

직원 누구나 클로드에게 말로 시켜 자기 업무의 수작업을 자동화할 수 있도록, 필요한 프로그램과 회사 규칙을 한 번에 설치합니다.

## 설치 (둘 중 하나)

**방법 1 — 명령 한 줄** (윈도우 키 → `PowerShell` 검색 → 열기 → 붙여 넣고 Enter)
```powershell
irm https://raw.githubusercontent.com/__OWNER__/drc-ai-starter/main/install.ps1 | iex
```

**방법 2 — 더블클릭**: 위 초록색 [Code] → Download ZIP → 압축 풀기 → `설치.bat` 더블클릭

점검만 하려면 `점검.bat`.

## 설치되는 것
| 프로그램 | 하는 일 |
|---|---|
| Claude Code · Claude 데스크톱 앱 | 말로 시키면 코드를 짜고 실행하는 클로드 |
| Git · GitHub CLI | 저장점(되돌리기), 깃허브 연결 |
| Node.js · Vercel CLI(65.0.0) | 만든 화면을 인터넷 주소로 게시, 리모션·HyperFrames 영상 |
| Python 3.14 + pandas·openpyxl·fastapi·playwright 등 | 자료 수집·계산·엑셀·사이트 자동 조작 |
| VS Code | 만든 파일 열어 보기 |
| FFmpeg | 영상·소리 변환 |
| 옵시디언 | 작업 기록·회사 지식 |
| 크롬 | Claude in Chrome 확장, 사이트 자동 조작 |
| Pretendard 글꼴 | 회사 화면·문서·영상 기본 글꼴 |
| 회사 규칙·스킬 | `~\클로드작업\CLAUDE.md`, 스킬 `자동화개발`·`화면기준` |

## 이 저장소에 없는 것
비밀번호·키·고객 정보·실적 자료는 들어 있지 않습니다. 각자 `.env`에 넣습니다(깃허브에 올라가지 않음).
