# =============================
# SheetFlow Windows 배포 스크립트 (자동 경로 감지 버전)
# =============================

# 1. Flutter Windows 빌드
Write-Host "🚀 Flutter Windows 빌드 시작..." -ForegroundColor Cyan
flutter clean
flutter pub get
flutter build windows

# 2. 경로 설정
$flutterBuildPath = "build/windows/x64/runner/Release"

# 백엔드 exe 자동 감지
$backendExe = Get-ChildItem -Path $flutterBuildPath -Filter "sheetflow_backend.exe" -File -Recurse -ErrorAction SilentlyContinue | Select-Object -First 1
if (-not $backendExe) {
    Write-Host "❌ 백엔드 exe(sheetflow_backend.exe)를 찾을 수 없습니다." -ForegroundColor Red
    exit 1
}
$backendExePath = $backendExe.FullName

# uploaded_files 폴더 자동 감지
$backendResources = Join-Path $flutterBuildPath "uploaded_files"
if (-not (Test-Path $backendResources)) {
    Write-Host "⚠ uploaded_files 폴더를 찾을 수 없습니다. (복사 건너뜀)" -ForegroundColor Yellow
}

# 최종 배포 폴더 경로
$outputPath = "release-package"

# 3. 기존 배포 폴더 삭제
if (Test-Path $outputPath) {
    Remove-Item $outputPath -Recurse -Force
}

# 4. 배포 폴더 생성
New-Item -ItemType Directory -Path $outputPath | Out-Null

# 5. Flutter 빌드 결과물 전체 복사 (exe + DLL + data 폴더)
Copy-Item "$flutterBuildPath\*" $outputPath -Recurse

# 6. 백엔드 exe 복사
Copy-Item $backendExePath $outputPath

# 7. 백엔드 리소스 폴더 복사 (있을 때만)
if (Test-Path $backendResources) {
    Copy-Item $backendResources $outputPath -Recurse
}

Write-Host "✅ 배포 폴더 생성 완료: $outputPath" -ForegroundColor Green
