@echo off
REM Build FanBeat Driver for HP Pavilion dv6

echo ===============================================
echo Building Fan Beat Driver (HP Pavilion dv6)
echo ===============================================
echo.

REM Assemble FanBeat module
echo [1/3] Assembling FanBeat.asm...
ml64 /c /Cp /Cx FanBeat.asm
if errorlevel 1 goto error

REM Assemble main driver
echo [2/3] Assembling FanBeatDriver.asm...
ml64 /c /Cp /Cx FanBeatDriver.asm
if errorlevel 1 goto error

REM Link
echo [3/3] Linking FanBeat.efi...
link /NOLOGO /SUBSYSTEM:EFI_APPLICATION /NODEFAULTLIB ^
     /ENTRY:_ModuleEntryPoint ^
     /OUT:FanBeat.efi /MACHINE:X64 ^
     FanBeatDriver.obj FanBeat.obj

if errorlevel 1 goto error

echo.
echo ===============================================
echo SUCCESS! FanBeat.efi created
echo ===============================================
echo.
echo IMPORTANT - READ BEFORE USE:
echo.
echo 1. This driver is EXPERIMENTAL and may damage your hardware!
echo 2. Only tested for HP Pavilion dv6 with InsydeH20 BIOS
echo 3. EC registers may be different on your specific model
echo 4. Use at your own risk!
echo.
echo To test safely:
echo 1. Listen carefully - you should hear the fan making beats
echo 2. If no sound, registers might be wrong for your model
echo 3. If fan goes crazy or won't stop, POWER OFF immediately
echo.
echo Deployment:
echo 1. Copy FanBeat.efi to FAT32 USB drive
echo 2. Boot to UEFI shell
echo 3. Run: fs0:\FanBeat.efi
echo 4. Or rename to \EFI\BOOT\BOOTX64.EFI for auto-boot
echo.
goto end

:error
echo.
echo ===============================================
echo BUILD FAILED!
echo ===============================================
echo.
echo Check that you have Visual Studio or Windows SDK installed
echo with ml64.exe and link.exe in your PATH.
echo.

:end
pause
