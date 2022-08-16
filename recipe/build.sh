export PREFIX_NSIS=$PREFIX/NSIS

pushd binary
cp -r . "$PREFIX_NSIS"
rm -rf $PREFIX_NSIS/Docs
rm -rf $PREFIX_NSIS/Examples
popd

pushd plugins
cp "UAC/U/UAC.dll" "$PREFIX_NSIS/Plugins/x86-unicode/"
cp "untgz/Plugins/x86-unicode/untgz.dll" "$PREFIX_NSIS/Plugins/x86-unicode/"
cp "UnicodePathTest/Plugin/UnicodePathTest.dll" "$PREFIX_NSIS/Plugins/x86-unicode/"
popd

scons_options="CC=\"${CC}\" CXX=\"${CXX}\" APPEND_CCFLAGS=\"${CXXFLAGS}\" APPEND_LINKFLAGS=\"${LDFLAGS}\""
scons_options+=" SKIPSTUBS=all SKIPPLUGINS=all SKIPUTILS=all SKIPMISC=all"
scons_options+=" NSIS_CONFIG_CONST_DATA_PATH=yes PREFIX=\"$PREFIX_NSIS\""
scons_options+=" -Q PATH=\"$PATH\""
scons_targets="install-compiler"
if [[ $nsis_variant == "log_enabled" ]]; then
  scons_options+=" NSIS_CONFIG_LOG=yes"
  scons_targets+=" install-stubs"
fi

cd src
scons $scons_options $scons_targets

mkdir -p $PREFIX/bin
ln -sf $PREFIX_NSIS/bin/makensis $PREFIX_NSIS/makensis.exe
ln -sf $PREFIX_NSIS/bin/makensis $PREFIX/bin/makensis

pushd $PREFIX_NSIS
  mkdir share
  cd share
  ln -sf $PREFIX_NSIS nsis
popd
