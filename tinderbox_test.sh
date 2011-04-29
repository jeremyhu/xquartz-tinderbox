#!/bin/bash
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

    JHBUILDRC="jhbuildrc.xquartz"
    ;;
  vincent)
    URL="http://jeremyhu-vincent:xQUGcg@tinderbox.x.org/builds/rpc"
    ;;
  tifa|tifa-linux32)
    CONFIG="tifa-linux32"
    JHBUILD="linux32 ${JHBUILD}"
    LD_LIBRARY_PATH="${JHBUILDDIR}/build/lib:${JHBUILDDIR}/external/build/lib${LD_LIBRARY_PATH+:${LD_LIBRARY_PATH}}"
    URL="http://jeremyhu-tifa-linux32:xFDSPr@tinderbox.x.org/builds/rpc"
    ;;
  tifa-linux64)
    TB_CFLAGS="-mminimal-toc"

    # libxcb does not like python3
    export PYTHON="/usr/bin/python2"
    LD_LIBRARY_PATH="${JHBUILDDIR}/build/lib:${JHBUILDDIR}/external/build/lib${LD_LIBRARY_PATH+:${LD_LIBRARY_PATH}}"
    URL="http://jeremyhu-tifa-linux64:JsFKEr4f6@tinderbox.x.org/builds/rpc"
    ;;
  *)
    echo "Invalid config: ${CONFIG}" >&2
    exit 1
    ;;
esac

JHBUILD="${JHBUILD} -f ${JHBUILDDIR}/${JHBUILDRC}"

[[ -d /usr/local/bin ]] && PATH="/usr/local/bin:${PATH}"
[[ -d /opt/local/bin ]] && PATH="/opt/local/bin:${PATH}"
[[ -d /opt/llvm/bin ]] && PATH="/opt/llvm/bin:${PATH}"
[[ -d "${HOME}/bin" ]] && PATH="${HOME}/bin:${PATH}"
PATH="${JHBUILDDIR}/build/bin:${JHBUILDDIR}/external/build/bin:${PATH}"

export ACLOCAL="aclocal -I ${JHBUILDDIR}/build/share/aclocal"
[[ -d /usr/local/share/aclocal ]] && ACLOCAL="${ACLOCAL} -I /usr/local/share/aclocal"

export PKG_CONFIG_PATH="${JHBUILDDIR}/build/share/pkgconfig:${JHBUILDDIR}/build/lib/pkgconfig:${JHBUILDDIR}/external/build/share/pkgconfig:${JHBUILDDIR}/external/build/lib/pkgconfig"
[[ -d /usr/X11 ]] && PKG_CONFIG_PATH="${PKG_CONFIG_PATH}:/usr/X11/share/pkgconfig:/usr/X11/lib/pkgconfig"

export FOP_OPTS="-Xmx2048m -Djava.awt.headless=true"

export CPPFLAGS="-I${JHBUILDDIR}/build/include -I${JHBUILDDIR}/external/build/include"
export CFLAGS="-O0 -pipe -Wall -Wformat=2 ${TB_CFLAGS}"
export OBJCFLAGS="${CFLAGS}"
export CXXFLAGS="${CFLAGS}"

[[ -d "${JHBUILDDIR}/build/share/aclocal" ]] || mkdir -p "${JHBUILDDIR}/build/share/aclocal"

upload_analyzer() {
    ssh jeremyhu@people.freedesktop.org mkdir -p w/${1} &&
    rsync --archive --force --whole-file --delete --delete-after --verbose --compress ${JHBUILDDIR}/${1}/ jeremyhu@people.freedesktop.org:w/${1}
}

upload_analyzer_results() {
    if [[ ! -r ${JHBUILDDIR}/fdo.rsa ]] ; then
        return 0
    fi

    rmdir ${JHBUILDDIR}/analyzer/${CONFIG}/* >& /dev/null

    eval $(/usr/bin/ssh-agent -s)
    /usr/bin/ssh-add "${JHBUILDDIR}/fdo.rsa"

    #perl -n -e "if(m/scan-build: Run 'scan-view .*\/(analyzer\/.*)' to examine bug reports\./) { print \$1.\"\n\";}" |
    #while read path ; do
    #    upload_analyzer "${path}" < /dev/null
    #done

    # Do one final rsync to sync old log removal
    upload_analyzer analyzer/${CONFIG}

    kill ${SSH_AGENT_PID}
}

#$JHBUILD clean
#$JHBUILD build --autogen --clean
#$JHBUILD build --autogen --clean --start-at=xserver
#$JHBUILD autobuild --autogen --verbose --report-url="${URL}"
$JHBUILD autobuild --autogen --clean --verbose --report-url="${URL}"

upload_analyzer_results

# Delete, so LS doesn't find it accidentally
if [[ $CONFIG = "yuffie" ]] ; then
  rm -rf "${JHBUILDDIR}/build/Applications"
fi
