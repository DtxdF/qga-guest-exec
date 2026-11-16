#!/bin/sh

#
# Script designed to be run for development purposes only.
#

"${SUEXEC:-doas}" make QGA_GUEST_EXEC_VERSION=`make -V QGA_GUEST_EXEC_VERSION`+`git rev-parse HEAD`
