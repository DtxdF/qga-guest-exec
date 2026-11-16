MKDIR?=mkdir -p
INSTALL?=install
SED?=sed -i ''
RM?=rm -f
PREFIX?=/usr/local
MANDIR?=${PREFIX}/share/man

QGA_GUEST_EXEC_VERSION?=0.1.0

.PHONY: all
all: install

.PHONY: install
install:
	${MKDIR} -m 755 -p "${DESTDIR}${MANDIR}"
	${MKDIR} -m 755 -p "${DESTDIR}${MANDIR}/man1"
	${INSTALL} -m 444 qga-guest-exec.1 "${DESTDIR}${MANDIR}/man1/qga-guest-exec.1"
	${MKDIR} -m 755 -p "${DESTDIR}${PREFIX}/bin"
	${INSTALL} -m 555 qga-guest-exec "${DESTDIR}${PREFIX}/bin/qga-guest-exec"
	${SED} -e 's|%%VERSION%%|${QGA_GUEST_EXEC_VERSION}|' "${DESTDIR}${PREFIX}/bin/qga-guest-exec"

.PHONY: uninstall
uninstall:
	${RM} "${DESTDIR}${MANDIR}/man1/qga-guest-exec.1"
	${RM} "${DESTDIR}${PREFIX}/bin/qga-guest-exec"

.PHONY: docs
docs: qga-guest-exec.1
	@mandoc -T ascii qga-guest-exec.1 | col -b | tail +3 | sed -e '$$d' | sed -e '$$d' | sed -e 's|%%PREFIX%%|${PREFIX}|' > README.txt
