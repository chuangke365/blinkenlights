Name "Starter Kit: Blinkenlights Demo <<DEMO_DOT_VERSION>>"

OutFile "starter_kit_blinkenlights_demo_windows_<<DEMO_UNDERSCORE_VERSION>>.exe"

XPStyle on

; The default installation directory
InstallDir "$PROGRAMFILES\Tinkerforge\Starter Kit Blinkenlights Demo"

; Registry key to check for directory (so if you install again, it will
; overwrite the old one automatically)
InstallDirRegKey HKLM "Software\Tinkerforge\Starter Kit Blinkenlights Demo" "Install_Dir"

; Request application privileges for Windows Vista
RequestExecutionLevel admin

;--------------------------------

!define DEMO_VERSION <<DEMO_DOT_VERSION>>

;--------------------------------

!macro macrouninstall

  DetailPrint "Uninstall Starter Kit: Blinkenlights Demo..."

  ; Remove directories used
  RMDir /R $INSTDIR

  ; Remove menu shortcuts
  Delete "$SMPROGRAMS\Tinkerforge\Starter Kit Blinkenlights Demo *.lnk"
  RMDir "$SMPROGRAMS\Tinkerforge"

  ; Remove registry keys
  DeleteRegKey HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\Tinkerforge Starter Kit Blinkenlights Demo"
  DeleteRegKey HKLM "Software\Tinkerforge\Starter Kit Blinkenlights Demo"

!macroend

; Pages

Page components
Page directory
Page instfiles

UninstPage uninstConfirm
UninstPage instfiles

;--------------------------------

Section /o "-uninstall old demo" SEC_UNINSTALL_OLD

  !insertmacro macrouninstall

SectionEnd

;--------------------------------

; The stuff to install
Section "Install Starter Kit: Blinkenlights Demo ${DEMO_VERSION}"
  SectionIn RO

  DetailPrint "Install Starter Kit: Blinkenlights Demo..."

  SetOutPath "$INSTDIR"
  File "..\*"

  ; Write the installation path into the registry
  WriteRegStr HKLM "Software\Tinkerforge\Starter Kit Blinkenlights Demo" "Install_Dir" "$INSTDIR"
  WriteRegStr HKLM "Software\Tinkerforge\Starter Kit Blinkenlights Demo" "Version" ${DEMO_VERSION}

  ; Write the uninstall keys for Windows
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\Tinkerforge Starter Kit Blinkenlights Demo" "DisplayName" "Tinkerforge Starter Kit: Blinkenlights Demo ${DEMO_VERSION}"
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\Tinkerforge Starter Kit Blinkenlights Demo" "DisplayIcon" '"$INSTDIR\demo-icon.ico"'
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\Tinkerforge Starter Kit Blinkenlights Demo" "DisplayVersion" "${DEMO_VERSION}"
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\Tinkerforge Starter Kit Blinkenlights Demo" "Publisher" "Tinkerforge GmbH"
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\Tinkerforge Starter Kit Blinkenlights Demo" "UninstallString" '"$INSTDIR\uninstall.exe"'
  WriteRegDWORD HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\Tinkerforge Starter Kit Blinkenlights Demo" "NoModify" 1
  WriteRegDWORD HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\Tinkerforge Starter Kit Blinkenlights Demo" "NoRepair" 1
  WriteUninstaller "uninstall.exe"

  ; Create start menu shortcut
  SetOutPath $INSTDIR\ ; set working directory for demo.exe
  createDirectory "$SMPROGRAMS\Tinkerforge"
  createShortCut "$SMPROGRAMS\Tinkerforge\Starter Kit Blinkenlights Demo ${DEMO_VERSION}.lnk" "$INSTDIR\demo.exe"

SectionEnd

;--------------------------------

!include "Sections.nsh"
!include "WinVer.nsh"

Function .onInit

  ; Check to see if already installed
  ClearErrors
  ReadRegStr $0 HKLM "Software\Tinkerforge\Starter Kit Blinkenlights Demo" "Version"
  IfErrors not_installed ; Version not set

  SectionSetText ${SEC_UNINSTALL_OLD} "Uninstall Starter Kit Blinkenlights Demo $0" ; make item visible
  IntOp $0 ${SF_SELECTED} | ${SF_RO}
  SectionSetFlags ${SEC_UNINSTALL_OLD} $0

not_installed:

FunctionEnd

;--------------------------------
; Uninstaller

Section "Uninstall"

  !insertmacro macrouninstall

SectionEnd
