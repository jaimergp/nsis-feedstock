set "PREFIX_NSIS=%PREFIX%\NSIS"
robocopy . "%PREFIX_NSIS%" /S /XF bld.bat Docs Examples
if errorlevel 1 exit 1

copy nsis_activate.bat "%PREFIX%\etc\conda\activate.d\"
if errorlevel 1 exit 1

cd ..
if errorlevel 1 exit 1

%PYTHON% "%RECIPE_DIR%\get_plugins.py"
if errorlevel 1 exit 1

copy "elevate\bin.x86-32\elevate.exe" "%PREFIX_NSIS%\Plugins\x86-unicode\"
if errorlevel 1 exit 1
copy "UAC\U\UAC.dll" "%PREFIX_NSIS%\Plugins\x86-unicode\"
if errorlevel 1 exit 1
copy "untgz\Plugins\x86-unicode\untgz.dll" "%PREFIX_NSIS%\Plugins\x86-unicode\"
if errorlevel 1 exit 1
copy "UnicodePathTest\Plugin\UnicodePathTest.dll" "%PREFIX_NSIS%\Plugins\x86-unicode\"
if errorlevel 1 exit 1

(
type "%SRC_DIR%\COPYING"||exit 1

echo(||exit 1
echo(=== UAC plugin license information ===||exit 1
type "UAC\License.txt"||exit 1

echo(||exit 1
echo(=== untgz plugin license information ===||exit 1
type "untgz\LICENSE.TXT"||exit 1

echo(||exit 1
echo(=== UnicodePathTest plugin license information ===||exit 1
type "UnicodePathTest\Readme.txt"||exit 1

echo(||exit 1
echo(=== elevate.exe license information ===||exit 1
echo(UNKNOWN LICENSE||exit 1
) > "LICENSE.txt"||exit 1

cd "%SRC_DIR%"
if errorlevel 1 exit 1

exit 0
