# 📊 SheetFlow

SheetFlow는 **엑셀 데이터 업로드, 중복 분석, 정렬, 시리얼 이상 탐지**를 지원하는 **데스크탑 앱**입니다.  
Flutter 프론트엔드와 FastAPI 백엔드로 구성되어 있으며, Windows 환경에서 실행 가능합니다.

---

## ✨ 주요 기능

- 📂 **엑셀 업로드** (`.xlsx`, `.xls`)
- 🔍 **중복 데이터 분석**
- 📑 **제품코드별 시리얼 추적**
- ↕ **데이터 정렬 기능**
- ⚠ **시리얼 이상 탐지**
- 📥 분석 결과 다운로드 (Excel)

---

## 🛠 기술 스택

| 영역        | 기술 |
|-------------|------|
| 프론트엔드  | Flutter (Windows Desktop) |
| 백엔드      | FastAPI, Python 3.12 |
| 데이터 처리 | Pandas, OpenPyXL, XlsxWriter |
| 배포        | PyInstaller, PowerShell Script |

---

## 📦 설치 방법

### 1. 실행 파일로 사용 (추천)
1. [GitHub Release](https://github.com/duckptr/sheetflow/releases)에서 최신 버전 다운로드
2. 압축 해제 후 `sheetflow.exe` 실행

### 2. 개발 모드로 실행
#### 백엔드
```bash
cd backend
python -m venv venv
venv\Scripts\activate
pip install -r requirements.txt
uvicorn main:app --reload

---

cd frontend
flutter pub get
flutter run -d windows

---

sheetflow/
├── backend/               # FastAPI 백엔드
│   ├── app/                # API 라우트 & 분석 로직
│   ├── uploaded_files/     # 업로드된 파일 저장 폴더 (ignore)
│   ├── requirements.txt
│   └── main.py
├── frontend/              # Flutter 프론트엔드
│   ├── lib/
│   ├── windows/
│   ├── assets/
│   └── deploy.ps1         # Windows 배포 스크립트
└── .gitignore


