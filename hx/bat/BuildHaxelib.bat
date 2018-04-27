@echo off
cd ../



set /p Version=<version.txt
del "dist\\StarlingAnimateCC %Version%.zip" /Q
rmdir dist\\temp /S /Q
timeout 1

pause

mkdir dist\\temp
xcopy src dist\\temp\\src /S /I
copy haxelib.json dist\\temp
call bat\\repl.bat "{version}" "%Version%" L < "haxelib.json" >"dist\\temp\\haxelib.json"
copy run.n dist\\temp

pause

powershell.exe -nologo -noprofile -command "& { Add-Type -A 'System.IO.Compression.FileSystem'; [IO.Compression.ZipFile]::CreateFromDirectory('dist\\temp', 'dist\\StarlingAnimateCC %Version%.zip'); }"
haxelib submit "dist\\StarlingAnimateCC %Version%.zip"
rmdir dist\\temp /S /Q
pause