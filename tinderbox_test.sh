#!/bin/bash

. /etc/profile
. /etc/bashrc
. ${HOME}/.profile
. ${HOME}/.bashrc

. ${HOME}/src/strip.sh
unset CFLAGS OBJCFLAGS CPPFLAGS LDFLAGS C_INCLUDE_PATH OBJC_INCLUDE_PATH CPLUS_INCLUDE_PATH PKG_CONFIG_PATH

PATH="/opt/llvm/bin:/opt/local/bin:$PATH"

#URL="http://jeremyhu-vincent:xQUGcg@tinderbox.x.org/builds/rpc"
URL="http://jeremyhu-yuffie:xQUGcg@tinderbox.x.org/builds/rpc"

#URL="http://jeremyhu-tifa-linux32:xFDSPr@tinderbox.x.org/builds/rpc"
#URL="http://jeremyhu-tifa-linux64:JsFKEr4f6@tinderbox.x.org/builds/rpc"

#jhbuild clean

#jhbuild build --autogen --clean --start-at=xserver
#jhbuild autobuild --autogen --verbose --report-url="${URL}"
jhbuild autobuild --autogen --clean --verbose --report-url="${URL}"

/bin/ls -1 /var/tmp | /usr/bin/head -n 2000 | /usr/bin/grep dSYM | /usr/bin/sed 's:^:/var/tmp/:' | /usr/bin/xargs /bin/rm -rf
/bin/ls -1 /var/tmp | /usr/bin/head -n 2000 | /usr/bin/grep dSYM | /usr/bin/sed 's:^:/var/tmp/:' | /usr/bin/xargs /bin/rm -rf
/bin/ls -1 /var/tmp | /usr/bin/head -n 2000 | /usr/bin/grep dSYM | /usr/bin/sed 's:^:/var/tmp/:' | /usr/bin/xargs /bin/rm -rf
/bin/ls -1 /var/tmp | /usr/bin/head -n 2000 | /usr/bin/grep dSYM | /usr/bin/sed 's:^:/var/tmp/:' | /usr/bin/xargs /bin/rm -rf
/bin/ls -1 /var/tmp | /usr/bin/head -n 2000 | /usr/bin/grep dSYM | /usr/bin/sed 's:^:/var/tmp/:' | /usr/bin/xargs /bin/rm -rf
/bin/ls -1 /var/tmp | /usr/bin/head -n 2000 | /usr/bin/grep dSYM | /usr/bin/sed 's:^:/var/tmp/:' | /usr/bin/xargs /bin/rm -rf
/bin/ls -1 /var/tmp | /usr/bin/head -n 2000 | /usr/bin/grep dSYM | /usr/bin/sed 's:^:/var/tmp/:' | /usr/bin/xargs /bin/rm -rf
/bin/ls -1 /var/tmp | /usr/bin/head -n 2000 | /usr/bin/grep dSYM | /usr/bin/sed 's:^:/var/tmp/:' | /usr/bin/xargs /bin/rm -rf

rm -rf /Users/jeremy/src/freedesktop/jhbuild/build/Applications
