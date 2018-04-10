@echo off

cd ../../
rd /s /q hx\src
md hx\src
haxelib run as3hx src/ hx/src/

set bat=%cd%/hx/bat/

:treeProcess
cd hx/src/
for %%f in (*.hx) do call %bat%DoReplacements.bat %bat% %%f
for /D %%d in (*) do (
    cd %%d
    call :treeProcess
    cd ..
)

cd %bat%
pause