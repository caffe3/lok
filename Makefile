#	$OpenBSD: Makefile,v 1.18 2020/07/30 17:45:44 millert Exp $

PROG=	awk
SRCS=	awkgram.tab.c lex.c b.c main.c parse.c proctab.c tran.c lib.c run.c reallocarray.c strlcpy.c strlcat.c
PKG_CONFIG?=	pkg-config
LDADD=	-lm
DPADD=	${LIBM}
CLEANFILES+=proctab.c maketab awkgram.tab.c awkgram.tab.h
CURDIR=	$(shell pwd)
CC?=	cc
HOSTCC?=	$(CC)
CFLAGS+=-I. -I${CURDIR} -DHAS_ISBLANK -DNDEBUG
HOSTCFLAGS+=-I. -I${CURDIR} -DHAS_ISBLANK -DNDEBUG
DESTDIR?=
PREFIX?=/usr
BINDIR=$(PREFIX)/bin
MANDIR=$(PREFIX)/man

all: $(PROG)

$(PROG): proctab.c
	$(CC) $(CFLAGS) $(SRCS) $(LDFLAGS) $(LDADD) -o $(PROG)

awkgram.tab.c awkgram.tab.h: awkgram.y
	${YACC} -o awkgram.tab.c -d ${CURDIR}/awkgram.y

proctab.c: awkgram.tab.h maketab.c
	${HOSTCC} ${HOSTCFLAGS} ${CURDIR}/maketab.c -o maketab
	./maketab awkgram.tab.h >proctab.c

install: $(PROG)
	install -D -m 755 $(PROG) $(DESTDIR)/$(BINDIR)/$(PROG)
	install -D -m 644 $(PROG).1 $(DESTDIR)/$(MANDIR)/man1/$(PROG).1

