set "PREFIX_NSIS=%PREFIX%\NSIS"
robocopy . "%PREFIX_NSIS%" /S /XF bld.bat Docs Examples
if errorlevel 1 exit 1

cd ..
if errorlevel 1 exit 1

%PYTHON% "%RECIPE_DIR%\get_plugins.py"
if errorlevel 1 exit 1

copy "UAC\Plugins\x86-unicode\UAC.dll " "%PREFIX_NSIS%\Plugins\x86-unicode\"
if errorlevel 1 exit 1
copy "Untgz\untgz\unicode\untgz.dll" "%PREFIX_NSIS%\Plugins\x86-unicode\"
if errorlevel 1 exit 1
copy "UnicodePathTest_1.0\Plugin\UnicodePathTest.dll" "%PREFIX_NSIS%\Plugins\x86-unicode\"
if errorlevel 1 exit 1

copy "%SRC_DIR%\COPYING" + "UAC\License.txt" + "Untgz\untgz\LICENSE.TXT" "LICENSE.txt"
if errorlevel 1 exit 1

cd "%SRC_DIR%"
if errorlevel 1 exit 1

exit 0
