@echo off
REM Build Fountaine APK and output to single location
echo Building Fountaine APK...

REM Build APK
call flutter build apk --release

REM Copy to root build folder with clean name
if exist "build\app\outputs\flutter-apk\app-release.apk" (
    copy "build\app\outputs\flutter-apk\app-release.apk" "build\Fountaine.apk" /Y
    echo.
    echo ========================================
    echo APK built successfully!
    echo Location: build\Fountaine.apk
    echo ========================================
) else (
    echo Build failed or APK not found
)
