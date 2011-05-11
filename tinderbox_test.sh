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

case $CONFIG in
  yuffie)
    URL="http://jeremyhu-yuffie:xQUGcg@tinderbox.x.org/builds/rpc"

    export CC="/opt/llvm/bin/clang"
    export OBJC="${CC}"
    export CXX="/opt/llvm/bin/clang++"
    export LIBTOOLIZE="glibtoolize"

#    TB_CFLAGS="-Wextra"

# Stage 1:
    TB_CFLAGS="${TB_CFLAGS} -Werror=implicit"
    TB_CFLAGS="${TB_CFLAGS} -Werror=nonnull"
    TB_CFLAGS="${TB_CFLAGS} -Werror=format-security"
    TB_CFLAGS="${TB_CFLAGS} -Werror=format-extra-args"
    TB_CFLAGS="${TB_CFLAGS} -Werror=format-y2k"
    TB_CFLAGS="${TB_CFLAGS} -Werror=init-self"
    TB_CFLAGS="${TB_CFLAGS} -Werror=main"
    TB_CFLAGS="${TB_CFLAGS} -Werror=missing-braces"
    TB_CFLAGS="${TB_CFLAGS} -Werror=parentheses"
    TB_CFLAGS="${TB_CFLAGS} -Werror=sequence-point"
    TB_CFLAGS="${TB_CFLAGS} -Werror=return-type"
    TB_CFLAGS="${TB_CFLAGS} -Werror=trigraphs"
    TB_CFLAGS="${TB_CFLAGS} -Werror=array-bounds"
    TB_CFLAGS="${TB_CFLAGS} -Wcast-align"
    TB_CFLAGS="${TB_CFLAGS} -Werror=write-strings"
#    TB_CFLAGS="${TB_CFLAGS} -Werror=clobbered"
    TB_CFLAGS="${TB_CFLAGS} -Werror=address"
    TB_CFLAGS="${TB_CFLAGS} -Werror=int-to-pointer-cast"
    TB_CFLAGS="${TB_CFLAGS} -Werror=pointer-to-int-cast"

# Stage 2:
#    TB_CFLAGS="${TB_CFLAGS} -Wlogical-op"
    TB_CFLAGS="${TB_CFLAGS} -Wunused"
    TB_CFLAGS="${TB_CFLAGS} -Wuninitialized"
    TB_CFLAGS="${TB_CFLAGS} -Wshadow"
#    TB_CFLAGS="${TB_CFLAGS} -Wunsafe-loop-optimizations"
    TB_CFLAGS="${TB_CFLAGS} -Wcast-qual"
    TB_CFLAGS="${TB_CFLAGS} -Wmissing-noreturn"
    TB_CFLAGS="${TB_CFLAGS} -Wmissing-format-attribute"
    TB_CFLAGS="${TB_CFLAGS} -Wredundant-decls"
    TB_CFLAGS="${TB_CFLAGS} -Wnested-externs"
    TB_CFLAGS="${TB_CFLAGS} -Winline"

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
    ;;
  tifa-linux64)
    TB_CFLAGS="-mminimal-toc"
    PREFIX="/var/tmp/jhbuild"

    # libxcb does not like python3
    export PYTHON="/usr/bin/python2"
    LD_LIBRARY_PATH="${PREFIX}/lib:${JHBUILDDIR}/external/build/lib${LD_LIBRARY_PATH+:${LD_LIBRARY_PATH}}"
    URL="http://jeremyhu-tifa-linux64:JsFKEr4f6@tinderbox.x.org/builds/rpc"
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
export CFLAGS="-O0 -pipe -Wall -Wformat=2 ${TB_CFLAGS}"
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
