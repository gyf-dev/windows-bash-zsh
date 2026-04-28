@echo off
setlocal EnableExtensions EnableDelayedExpansion

set "SCRIPT_DIR=%~dp0"
set "PS_SCRIPT=%SCRIPT_DIR%install.ps1"
set "PS_EXE="

for %%I in ("%SCRIPT_DIR:~0,-1%") do set "SKILL_NAME=%%~nxI"

where powershell.exe >nul 2>nul
if %ERRORLEVEL%==0 (
  set "PS_EXE=powershell.exe"
) else (
  where pwsh.exe >nul 2>nul
  if %ERRORLEVEL%==0 set "PS_EXE=pwsh.exe"
)

if not "%PS_EXE%"=="" (
  if not exist "%PS_SCRIPT%" (
    echo install.ps1 was not found next to this cmd file.
    exit /b 1
  )

  "%PS_EXE%" -NoProfile -ExecutionPolicy Bypass -File "%PS_SCRIPT%" %*
  exit /b %ERRORLEVEL%
)

echo PowerShell was not found. Using the pure CMD fallback.

set "TARGETS=all"
set "EXTRA_SKILL_ROOTS="
set "DRY_RUN=0"
set "YES=0"
set "UNINSTALL=0"

:parse_args
if "%~1"=="" goto after_parse_args

if /I "%~1"=="-Targets" (
  if "%~2"=="" goto missing_value
  set "TARGETS=%~2"
  shift
  shift
  goto parse_args
)
if /I "%~1"=="--targets" (
  if "%~2"=="" goto missing_value
  set "TARGETS=%~2"
  shift
  shift
  goto parse_args
)
if /I "%~1"=="-ExtraSkillRoots" (
  if "%~2"=="" goto missing_value
  set "EXTRA_SKILL_ROOTS=%~2"
  shift
  shift
  goto parse_args
)
if /I "%~1"=="--extra-skill-roots" (
  if "%~2"=="" goto missing_value
  set "EXTRA_SKILL_ROOTS=%~2"
  shift
  shift
  goto parse_args
)
if /I "%~1"=="-DryRun" (
  set "DRY_RUN=1"
  shift
  goto parse_args
)
if /I "%~1"=="--dry-run" (
  set "DRY_RUN=1"
  shift
  goto parse_args
)
if /I "%~1"=="-Yes" (
  set "YES=1"
  shift
  goto parse_args
)
if /I "%~1"=="--yes" (
  set "YES=1"
  shift
  goto parse_args
)
if /I "%~1"=="-Uninstall" (
  set "UNINSTALL=1"
  shift
  goto parse_args
)
if /I "%~1"=="--uninstall" (
  set "UNINSTALL=1"
  shift
  goto parse_args
)
if /I "%~1"=="-h" goto usage
if /I "%~1"=="--help" goto usage
if /I "%~1"=="/?" goto usage

echo Unknown option: %~1
goto usage_error

:missing_value
echo Missing value for %~1
goto usage_error

:after_parse_args
if not exist "%SCRIPT_DIR%SKILL.md" (
  echo SKILL.md was not found. Run this script from inside a skill repository.
  exit /b 1
)

echo Source skill: %SCRIPT_DIR:~0,-1%
echo Skill name:   %SKILL_NAME%
if "%UNINSTALL%"=="1" (
  echo Mode:         uninstall
) else (
  echo Mode:         install
)

if /I "%TARGETS%"=="all" (
  call :process_target codex
  call :process_target claude
  call :process_target agents
  call :process_target copilot
) else (
  for %%T in (%TARGETS:,= %) do call :process_target %%T
)

if not "%EXTRA_SKILL_ROOTS%"=="" call :process_extra_roots "%EXTRA_SKILL_ROOTS%"

echo Done.
exit /b 0

:process_target
set "TARGET=%~1"
set "ROOT="

if /I "%TARGET%"=="codex" (
  if defined CODEX_HOME (set "ROOT=%CODEX_HOME%\skills") else set "ROOT=%USERPROFILE%\.codex\skills"
) else if /I "%TARGET%"=="claude" (
  if defined CLAUDE_HOME (set "ROOT=%CLAUDE_HOME%\skills") else set "ROOT=%USERPROFILE%\.claude\skills"
) else if /I "%TARGET%"=="agents" (
  if defined AGENTS_HOME (set "ROOT=%AGENTS_HOME%\skills") else set "ROOT=%USERPROFILE%\.agents\skills"
) else if /I "%TARGET%"=="copilot" (
  if defined COPILOT_HOME (set "ROOT=%COPILOT_HOME%\skills") else set "ROOT=%USERPROFILE%\.copilot\skills"
) else (
  echo Unknown target: %TARGET%
  exit /b 2
)

if "%UNINSTALL%"=="1" (
  call :uninstall_one "%TARGET%" "%ROOT%"
) else (
  call :install_one "%TARGET%" "%ROOT%" "0"
)
exit /b %ERRORLEVEL%

:process_extra_roots
set "REMAINING=%~1"
:extra_loop
if "%REMAINING%"=="" exit /b 0
for /F "tokens=1* delims=," %%A in ("!REMAINING!") do (
  set "ONE_ROOT=%%~A"
  set "REMAINING=%%~B"
)
if not "!ONE_ROOT!"=="" (
  if "%UNINSTALL%"=="1" (
    call :uninstall_one "custom" "!ONE_ROOT!"
  ) else (
    call :install_one "custom" "!ONE_ROOT!" "1"
  )
)
goto extra_loop

:install_one
set "NAME=%~1"
set "ROOT=%~2"
set "CREATE_ROOT=%~3"
set "DEST=%ROOT%\%SKILL_NAME%"

if not exist "%ROOT%\" (
  if "%CREATE_ROOT%"=="1" (
    if "%DRY_RUN%"=="1" (
      echo [dry-run] %NAME% root would be created: %ROOT%
    ) else (
      mkdir "%ROOT%" >nul 2>nul
      if errorlevel 1 (
        echo Failed to create %NAME% skill root: %ROOT%
        exit /b 1
      )
    )
  ) else (
    echo Skipped %NAME%: skill root not found: %ROOT%
    exit /b 0
  )
)

if "%DRY_RUN%"=="1" (
  echo [dry-run] %NAME% -^> %DEST%
  if exist "%DEST%\" echo [dry-run] existing skill would prompt for replacement: %DEST%
  exit /b 0
)

if exist "%DEST%\" (
  if "%YES%"=="1" (
    rmdir /S /Q "%DEST%"
    if exist "%DEST%\" (
      echo Failed to replace existing %NAME% skill: %DEST%
      exit /b 1
    )
    echo Replaced existing %NAME% skill: %DEST%
  ) else (
    set "ANSWER="
    set /P "ANSWER=Existing %NAME% skill found at %DEST%. Replace? [Y/n] "
    if /I "!ANSWER:~0,1!"=="n" (
      echo Skipped %NAME%: existing skill was kept.
      exit /b 0
    )
    rmdir /S /Q "%DEST%"
    if exist "%DEST%\" (
      echo Failed to replace existing %NAME% skill: %DEST%
      exit /b 1
    )
    echo Replaced existing %NAME% skill: %DEST%
  )
)

mkdir "%DEST%" >nul 2>nul
if errorlevel 1 (
  echo Failed to create %NAME% skill directory: %DEST%
  exit /b 1
)
copy /Y "%SCRIPT_DIR%SKILL.md" "%DEST%\SKILL.md" >nul
if errorlevel 1 (
  echo Failed to copy SKILL.md to: %DEST%
  exit /b 1
)

for %%D in (agents assets references scripts) do (
  if exist "%DEST%\%%D\" rmdir /S /Q "%DEST%\%%D"
  if exist "%SCRIPT_DIR%%%D\" xcopy "%SCRIPT_DIR%%%D" "%DEST%\%%D\" /E /I /Y >nul
  if errorlevel 2 (
    echo Failed to copy %%D to: %DEST%\%%D
    exit /b 1
  )
)

echo Installed %NAME% skill: %DEST%
exit /b 0

:uninstall_one
set "NAME=%~1"
set "ROOT=%~2"
set "DEST=%ROOT%\%SKILL_NAME%"

if not exist "%ROOT%\" (
  echo Skipped %NAME%: skill root not found: %ROOT%
  exit /b 0
)

if not exist "%DEST%\" (
  echo Skipped %NAME%: skill not installed: %DEST%
  exit /b 0
)

if "%DRY_RUN%"=="1" (
  echo [dry-run] %NAME% would be removed: %DEST%
  exit /b 0
)

rmdir /S /Q "%DEST%"
if exist "%DEST%\" (
  echo Failed to uninstall %NAME% skill: %DEST%
  exit /b 1
)
echo Uninstalled %NAME% skill: %DEST%
exit /b 0

:usage
echo Usage: install.cmd [options]
echo.
echo Options:
echo   -Targets ^<list^>           Target list: all,codex,claude,agents,copilot
echo   -ExtraSkillRoots ^<list^>   Extra skills root directories, comma separated
echo   -DryRun                     Preview actions without writing files
echo   -Yes                        Replace existing skill without prompting
echo   -Uninstall                  Remove windows-bash-zsh from target skills roots
echo   -h, --help                  Show this help
echo.
echo Examples:
echo   install.cmd
echo   install.cmd -DryRun
echo   install.cmd -Targets codex
echo   install.cmd -Targets copilot -Uninstall
echo   install.cmd -ExtraSkillRoots "D:\MyAgent\skills"
exit /b 0

:usage_error
call :usage
exit /b 2
