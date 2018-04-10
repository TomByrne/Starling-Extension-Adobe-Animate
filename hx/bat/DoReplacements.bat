
set bat=%1
set target=%cd%\%2

echo %target%
ren "%2" "%22"

call %bat%repl.bat "starling.assets.AssetManager" "starling.utils.AssetManager" L < "%target%2" >"%target%"
call %bat%repl.bat "Array</*AS3HX WARNING no type*/>" "Array<Dynamic>" L < "%target%2" >"%target%"


del "%22"