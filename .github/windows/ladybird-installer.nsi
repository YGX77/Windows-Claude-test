; Builds the per-user Windows installer for Ladybird.
;
; Required defines (pass with /D on the makensis command line):
;   STAGE   absolute path of the folder that holds the release's bin\ and share\ folders, LICENSE and NOTICE.txt
;   OUTFILE absolute path of the installer to write
;   VERSION version text shown in Windows' installed-apps list (optional)

Unicode true
!include "MUI2.nsh"

!ifndef STAGE
  !error "Define STAGE, the folder that holds bin\ and share\"
!endif
!ifndef OUTFILE
  !error "Define OUTFILE, the installer to write"
!endif
!ifndef VERSION
  !define VERSION "0.0.0"
!endif

!define UNINSTALL_KEY "Software\Microsoft\Windows\CurrentVersion\Uninstall\Ladybird"

Name "Ladybird"
OutFile "${OUTFILE}"
; Installs for the current user only, so no administrator prompt is needed.
RequestExecutionLevel user
InstallDir "$LOCALAPPDATA\Programs\Ladybird"
InstallDirRegKey HKCU "Software\Ladybird" "InstallDir"
SetCompressor /SOLID lzma

!define MUI_ABORTWARNING
!define MUI_FINISHPAGE_RUN "$INSTDIR\bin\Ladybird.exe"
!define MUI_FINISHPAGE_RUN_TEXT "Start Ladybird"

!insertmacro MUI_PAGE_DIRECTORY
!insertmacro MUI_PAGE_INSTFILES
!insertmacro MUI_PAGE_FINISH
!insertmacro MUI_UNPAGE_CONFIRM
!insertmacro MUI_UNPAGE_INSTFILES
!insertmacro MUI_LANGUAGE "English"

Section "Ladybird" SecMain
  SectionIn RO

  ; Ladybird.exe finds its helper programs next to itself and its resources in ..\share, so keep this layout.
  SetOutPath "$INSTDIR\bin"
  File /r "${STAGE}\bin\*.*"
  SetOutPath "$INSTDIR\share"
  File /r "${STAGE}\share\*.*"

  ; BSD license terms: the license text must come with the binaries.
  SetOutPath "$INSTDIR"
  File "${STAGE}\LICENSE"
  File "${STAGE}\NOTICE.txt"

  WriteUninstaller "$INSTDIR\Uninstall.exe"

  SetOutPath "$INSTDIR\bin"
  CreateDirectory "$SMPROGRAMS\Ladybird"
  CreateShortcut "$SMPROGRAMS\Ladybird\Ladybird.lnk" "$INSTDIR\bin\Ladybird.exe"
  CreateShortcut "$SMPROGRAMS\Ladybird\Uninstall Ladybird.lnk" "$INSTDIR\Uninstall.exe"
  CreateShortcut "$DESKTOP\Ladybird.lnk" "$INSTDIR\bin\Ladybird.exe"

  WriteRegStr HKCU "Software\Ladybird" "InstallDir" "$INSTDIR"
  WriteRegStr HKCU "${UNINSTALL_KEY}" "DisplayName" "Ladybird"
  WriteRegStr HKCU "${UNINSTALL_KEY}" "DisplayVersion" "${VERSION}"
  WriteRegStr HKCU "${UNINSTALL_KEY}" "DisplayIcon" "$INSTDIR\bin\Ladybird.exe"
  WriteRegStr HKCU "${UNINSTALL_KEY}" "InstallLocation" "$INSTDIR"
  WriteRegStr HKCU "${UNINSTALL_KEY}" "UninstallString" '"$INSTDIR\Uninstall.exe"'
  WriteRegDWORD HKCU "${UNINSTALL_KEY}" "NoModify" 1
  WriteRegDWORD HKCU "${UNINSTALL_KEY}" "NoRepair" 1
SectionEnd

Section "Uninstall"
  Delete "$DESKTOP\Ladybird.lnk"
  Delete "$SMPROGRAMS\Ladybird\Ladybird.lnk"
  Delete "$SMPROGRAMS\Ladybird\Uninstall Ladybird.lnk"
  RMDir "$SMPROGRAMS\Ladybird"

  ; Remove only what the installer put there, never the whole chosen folder.
  RMDir /r "$INSTDIR\bin"
  RMDir /r "$INSTDIR\share"
  Delete "$INSTDIR\LICENSE"
  Delete "$INSTDIR\NOTICE.txt"
  Delete "$INSTDIR\Uninstall.exe"
  RMDir "$INSTDIR"

  DeleteRegKey HKCU "${UNINSTALL_KEY}"
  DeleteRegKey HKCU "Software\Ladybird"
SectionEnd
