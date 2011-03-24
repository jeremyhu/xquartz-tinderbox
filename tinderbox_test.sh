#!/bin/bash
# http://www.x.org/wiki/Tinderbox
# Visit http://tinderbox.x.org/account/ to add more machines.

if [[ $# -eq 0 ]] ; then
  CONFIG="$(hostname -s)"
else
  CONFIG=$1
fi

export JHBUILDDIR="${HOME}/src/freedesktop/jhbuild"
JHBUILDRC="jhbuildrc.linux"
JHBUILD="jhbuild"

[[ -d /usr/local/bin ]] && PATH="/usr/local/bin:${PATH}"
[[ -d /opt/local/bin ]] && PATH="/opt/local/bin:${PATH}"
[[ -d /opt/llvm/bin ]] && PATH="/opt/llvm/bin:${PATH}"

case $CONFIG in
  yuffie)
    . /etc/profile
    . /etc/bashrc
    . ${HOME}/.profile
    . ${HOME}/.bashrc
    . ${HOME}/src/strip.sh

    unset CFLAGS OBJCFLAGS CPPFLAGS LDFLAGS C_INCLUDE_PATH OBJC_INCLUDE_PATH CPLUS_INCLUDE_PATH PKG_CONFIG_PATH

    URL="http://jeremyhu-yuffie:xQUGcg@tinderbox.x.org/builds/rpc"

    export CC="/opt/llvm/bin/clang"
    export CXX="/opt/llvm/bin/clang++"
    export LIBTOOLIZE="glibtoolize"

    JHBUILDRC="jhbuildrc.xquartz"
    ;;
  vincent)
    URL="http://jeremyhu-vincent:xQUGcg@tinderbox.x.org/builds/rpc"
    ;;
  tifa|tifa-linux32)
    JHBUILD="linux32 ${JHBUILD}"
    URL="http://jeremyhu-tifa-linux32:xFDSPr@tinderbox.x.org/builds/rpc"
    ;;
  tifa-linux64)
    URL="http://jeremyhu-tifa-linux64:JsFKEr4f6@tinderbox.x.org/builds/rpc"
    ;;
  *)
    echo "Invalid config: ${CONFIG}" >&2
    exit 1
    ;;
esac

export ACLOCAL="aclocal -I ${JHBUILDDIR}/build/share/aclocal"
[[ -d "${JHBUILDDIR}/build/share/aclocal" ]] || mkdir -p "${JHBUILDDIR}/build/share/aclocal"
[[ -d /usr/local/share/aclocal ]] && ACLOCAL="${ACLOCAL} -I /usr/local/share/aclocal"
export PKG_CONFIG_PATH="${JHBUILDDIR}/build/share/pkgconfig:${JHBUILDDIR}/build/lib/pkgconfig:${JHBUILDDIR}/external/build/share/pkgconfig:${JHBUILDDIR}/external/build/lib/pkgconfig"
export FOP_OPTS="-Xmx2048m -Djava.awt.headless=true"
export CPPFLAGS="-I${JHBUILDDIR}/build/include -I${JHBUILDDIR}/external/build/include"
export CFLAGS="-O0 -pipe -Wall -Wformat=2"

JHBUILD="${JHBUILD} -f ${JHBUILDDIR}/${JHBUILDRC}"

#$JHBUILD clean
#$JHBUILD build --autogen --clean
#$JHBUILD build --autogen --clean --start-at=xserver
#$JHBUILD autobuild --autogen --verbose --report-url="${URL}"
$JHBUILD autobuild --autogen --clean --verbose --report-url="${URL}"

# Delete, so LS doesn't find it accidentally
if [[ $CONFIG = "yuffie" ]] ; then
  rm -rf "${JHBUILD_DIR}/build/Applications"
fi
