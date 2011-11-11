#!/bin/bash -ex
# http://www.x.org/wiki/Tinderbox
# Visit http://tinderbox.x.org/account/ to add more machines.

if [[ $# -eq 0 ]] ; then
  CONFIG="$(hostname -s)${SCHROOT_SESSION_ID+"-${SCHROOT_SESSION_ID}"}"
else
  CONFIG=$1
fi
export CONFIG

export JHBUILDDIR="${HOME}/src/freedesktop/jhbuild${SCHROOT_SESSION_ID+"-${SCHROOT_SESSION_ID}"}"
JHBUILDRC="jhbuildrc.linux"
JHBUILD="jhbuild"

export STATIC_ANALYSIS=True

# Stage 1:
#TB_CFLAGS="${TB_CFLAGS} -Werror=clobbered"
#TB_CFLAGS="${TB_CFLAGS} -Wlogical-op"
#TB_CFLAGS="${TB_CFLAGS} -Wparentheses"
#TB_CFLAGS="${TB_CFLAGS} -Wcast-align"
#TB_CFLAGS="${TB_CFLAGS} -Wunsafe-loop-optimizations"

case $CONFIG in
  yuffie)
    URL="http://jeremyhu-yuffie:xQUGcg@tinderbox.x.org/builds/rpc"

    #export CC="/opt/llvm/bin/clang"
    export CC="/opt/local/bin/clang-mp-3.0"
    export OBJC="${CC}"
    #export CXX="/opt/llvm/bin/clang++"
    export CXX="/opt/local/bin/clang++-mp-3.0"
    export LIBTOOLIZE="glibtoolize"

    TB_CFLAGS="${TB_CFLAGS} -fdiagnostics-show-category=name"

    JHBUILDRC="jhbuildrc.xquartz"
    ;;
  vincent)
    URL="http://jeremyhu-vincent:xQUGcg@tinderbox.x.org/builds/rpc"
    ;;
  tifa|tifa-linux32)
    CONFIG="tifa-linux32"
    PREFIX="/var/tmp/jhbuild"
    JHBUILD="linux32 ${JHBUILD}"
    LD_LIBRARY_PATH="${PREFIX}/lib:${JHBUILDDIR}/external/build/lib${LD_LIBRARY_PATH+:${LD_LIBRARY_PATH}}"
    URL="http://jeremyhu-tifa-linux32:xFDSPr@tinderbox.x.org/builds/rpc"

    TB_CFLAGS="${TB_CFLAGS} -D_XOPEN_SOURCE=600"

    # http://llvm.org/bugs/show_bug.cgi?id=11028
    export STATIC_ANALYSIS=False
    ;;
  tifa-linux64)
    TB_CFLAGS="${TB_CFLAGS} -mminimal-toc"
    PREFIX="/var/tmp/jhbuild"

    # libxcb does not like python3
    export PYTHON="/usr/bin/python2"
    LD_LIBRARY_PATH="${PREFIX}/lib:${JHBUILDDIR}/external/build/lib${LD_LIBRARY_PATH+:${LD_LIBRARY_PATH}}"
    URL="http://jeremyhu-tifa-linux64:JsFKEr4f6@tinderbox.x.org/builds/rpc"

    # http://llvm.org/bugs/show_bug.cgi?id=11028
    export STATIC_ANALYSIS=False
    ;;
  *)
    echo "Invalid config: ${CONFIG}" >&2
    exit 1
    ;;
esac

export PREFIX=${PREFIX-"${JHBUILDDIR}/build"}

JHBUILD="${JHBUILD} -f ${JHBUILDDIR}/${JHBUILDRC}"

[[ -d /usr/local/bin ]] && PATH="/usr/local/bin:${PATH}"
[[ -d /opt/local/bin ]] && PATH="/opt/local/bin:${PATH}"
[[ -d /opt/llvm/bin ]] && PATH="/opt/llvm/bin:${PATH}"
[[ -d "${HOME}/bin" ]] && PATH="${HOME}/bin:${PATH}"
PATH="${PREFIX}/bin:${JHBUILDDIR}/external/build/bin:${PATH}"

export ACLOCAL="aclocal -I ${PREFIX}/share/aclocal"
[[ -d /usr/local/share/aclocal ]] && ACLOCAL="${ACLOCAL} -I /usr/local/share/aclocal"

export PKG_CONFIG_PATH="${PREFIX}/share/pkgconfig:${PREFIX}/lib/pkgconfig:${JHBUILDDIR}/external/build/share/pkgconfig:${JHBUILDDIR}/external/build/lib/pkgconfig"
[[ -d /usr/X11 ]] && PKG_CONFIG_PATH="${PKG_CONFIG_PATH}:/usr/X11/share/pkgconfig:/usr/X11/lib/pkgconfig"

export FOP_OPTS="-Xmx2048m -Djava.awt.headless=true"

export CPPFLAGS="-I${PREFIX}/include -I${JHBUILDDIR}/external/build/include"
export CFLAGS="-O0 -pipe -Wall -Wextra -Wno-sign-compare -Wno-unused-parameter -Wno-missing-field-initializers -Wformat=2 ${TB_CFLAGS}"
export OBJCFLAGS="${CFLAGS}"
export CXXFLAGS="${CFLAGS}"

[[ -d "${PREFIX}/share/aclocal" ]] || mkdir -p "${PREFIX}/share/aclocal"

export ANALYZERSUBDIR="analyzer/${CONFIG}/$(date +"%Y%m%d-%H%M")"
[[ -r ${JHBUILDDIR}/fdo.rsa ]] && mkdir -p ${JHBUILDDIR}/${ANALYZERSUBDIR}

upload_analyzer_results() {
    if [[ ! -r ${JHBUILDDIR}/fdo.rsa ]] ; then
        return 0
    fi

    # Remove empty directories
    rmdir ${JHBUILDDIR}/${ANALYZERSUBDIR}/* >& /dev/null || true
    rmdir ${JHBUILDDIR}/${ANALYZERSUBDIR} >& /dev/null || true

    if [[ ! -d "${JHBUILDDIR}/${ANALYZERSUBDIR}" ]] ; then
        return 0
    fi

    # Remove analyzer's created subdirectories
    for projdir in ${JHBUILDDIR}/${ANALYZERSUBDIR}/* ; do
        mv ${projdir}/20*-*-*-*/* ${projdir}
	rmdir ${projdir}/20*-*-*-*
    done

    eval $(/usr/bin/ssh-agent -s)
    /usr/bin/ssh-add "${JHBUILDDIR}/fdo.rsa"

    ssh jeremyhu@people.freedesktop.org mkdir -p w/${ANALYZERSUBDIR}
    rsync --archive --force --whole-file --delete --delete-after --verbose --compress ${JHBUILDDIR}/${ANALYZERSUBDIR}/ jeremyhu@people.freedesktop.org:w/${ANALYZERSUBDIR}

    kill ${SSH_AGENT_PID}
}

#$JHBUILD clean
#$JHBUILD build --autogen --clean
#$JHBUILD build --autogen --clean --start-at=xserver
#$JHBUILD autobuild --autogen --verbose --report-url="${URL}"
$JHBUILD autobuild --autogen --clean --verbose --report-url="${URL}" || true

upload_analyzer_results

# Delete, so LS doesn't find it accidentally
if [[ $CONFIG = "yuffie" ]] ; then
  rm -rf "${PREFIX}/Applications"
fi
