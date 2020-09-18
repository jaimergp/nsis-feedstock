export PREFIX_NSIS=$PREFIX/NSIS

pushd binary
cp -r . "$PREFIX_NSIS"
rm -rf $PREFIX_NSIS/Docs
rm -rf $PREFIX_NSIS/Examples
popd

ln -s $(which $CC) $BUILD_PREFIX/bin/gcc
ln -s $(which $CXX) $BUILD_PREFIX/bin/g++

pushd plugins
cp "UAC/U/UAC.dll" "$PREFIX_NSIS/Plugins/x86-unicode/"
cp "untgz/Plugins/x86-unicode/untgz.dll" "$PREFIX_NSIS/Plugins/x86-unicode/"
cp "UnicodePathTest/Plugin/UnicodePathTest.dll" "$PREFIX_NSIS/Plugins/x86-unicode/"

(
cat "$SRC_DIR/binary/COPYING" || exit 1

echo ""
echo "=== UAC plugin license information ==="
cat "UAC/License.txt" || exit 1

echo ""
echo "=== untgz plugin license information ==="
cat "untgz/LICENSE.TXT" || exit 1

echo ""
echo "=== UnicodePathTest plugin license information ==="
cat "UnicodePathTest/Readme.txt" ||exit 1

) > "$SRC_DIR/LICENSE.txt" || exit 1

popd

cd src
sed -i.bak "s/#ifndef NSIS_CONFIG_CONST_DATA_PATH/#if 1/g" Source/build.cpp
scons SKIPSTUBS=all SKIPPLUGINS=all SKIPUTILS=all SKIPMISC=all NSIS_CONFIG_CONST_DATA=no PREFIX=$PREFIX_NSIS install-compiler

mkdir -p $PREFIX/bin
ln -sf $PREFIX_NSIS/bin/makensis $PREFIX_NSIS/makensis.exe
ln -sf $PREFIX_NSIS/bin/makensis $PREFIX/bin/makensis

pushd $PREFIX_NSIS
  mkdir share
  cd share
  ln -sf $PREFIX_NSIS nsis
popd

