:user_configuration

:: Path to Flex SDK
set FLEX_SDK=D:\flex36_air27
rem set ANDROID_SDK=E:\Program Files (x86)\Android\android-sdk
set ANDROID_SDK=D:\android-sdk-windows

:validation
if not exist "%FLEX_SDK%" goto flexsdk
if not exist "%ANDROID_SDK%" goto androidsdk
goto succeed

:flexsdk
echo.
echo ERROR: incorrect path to Flex SDK in 'bat\SetupSDK.bat'
echo.
echo %FLEX_SDK%
echo.
if %PAUSE_ERRORS%==1 pause
exit

:androidsdk
echo.
echo ERROR: incorrect path to Android SDK in 'bat\SetupSDK.bat'
echo.
echo %ANDROID_SDK%
echo.
if %PAUSE_ERRORS%==1 pause
exit

:succeed
set PATH=%PATH%;%FLEX_SDK%\bin;%ANDROID_SDK%\platform-tools
adb devices
