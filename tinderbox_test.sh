#!/bin/bash

. /etc/profile
. /etc/bashrc
. ${HOME}/.profile
. ${HOME}/.bashrc

. ${HOME}/src/strip.sh
unset CFLAGS OBJCFLAGS CPPFLAGS LDFLAGS C_INCLUDE_PATH OBJC_INCLUDE_PATH CPLUS_INCLUDE_PATH PKG_CONFIG_PATH

PATH="$PATH:/opt/local/bin"

#URL="http://jeremyhu-vincent:xQUGcg@tinderbox.x.org/builds/rpc"
URL="http://jeremyhu-yuffie:xQUGcg@tinderbox.x.org/builds/rpc"

rm /Users/jeremy/src/freedesktop/jhbuild/configure-cache

#jhbuild clean

#jhbuild build --start-at=libX11
#jhbuild autobuild --autogen --verbose --report-url="${URL}"
jhbuild autobuild --autogen --clean --verbose --report-url="${URL}"

/bin/ls -1 /var/tmp | /usr/bin/head -n 9000 | /usr/bin/grep dSYM | /usr/bin/sed 's:^:/var/tmp/:' | /usr/bin/xargs /bin/rm -rf
/bin/ls -1 /var/tmp | /usr/bin/head -n 9000 | /usr/bin/grep dSYM | /usr/bin/sed 's:^:/var/tmp/:' | /usr/bin/xargs /bin/rm -rf

rm -rf /Users/jeremy/src/freedesktop/jhbuild/build/Applications