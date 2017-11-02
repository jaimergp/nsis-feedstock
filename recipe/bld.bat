robocopy . "%PREFIX%" /S /XF bld.bat
if errorlevel NEQ 1 exit 1

cd ..
if errorlevel 1 exit 1

%PYTHON% "%RECIPE_DIR%\get_plugins.py"
if errorlevel 1 exit 1

copy "UAC\Plugins\x86-unicode\UAC.dll " "%PREFIX%\Plugins\x86-unicode\"
if errorlevel 1 exit 1
copy "Untgz\untgz\unicode\untgz.dll" "%PREFIX%\Plugins\x86-unicode\"
if errorlevel 1 exit 1
copy "UnicodePathTest_1.0\Plugin\UnicodePathTest.dll" "%PREFIX%\Plugins\x86-unicode\"
if errorlevel 1 exit 1

cd "%SRC_DIR%"
if errorlevel 1 exit 1

exit 0
