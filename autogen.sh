#!/bin/sh -e

include ()
{
    # If we keep a copy of the kernel header in the SVN tree, we'll have
    # to worry about synchronization issues forever. Instead, we just copy 
    # the headers that we need from the lastest kernel version at autogen
    # stage.

    INCLUDEDIR=${KERNEL_DIR:-/lib/modules/`uname -r`/build}/include/linux
    if [ -f $INCLUDEDIR/netfilter/nfnetlink_log.h ]
    then
    	TARGET=include/libnetfilter_log/linux_nfnetlink_log.h
    	echo "Copying nfnetlink_log.h to linux_nfnetlink_log.h"
    	cp $INCLUDEDIR/netfilter/nfnetlink_log.h $TARGET
	TEMP=`tempfile`
	sed 's/linux\/netfilter\/nfnetlink.h/libnfnetlink\/linux_nfnetlink.h/g' $TARGET > $TEMP
	# Add aligned_u64 definition after #define _NFNETLINK_LOG_H
	awk '{
        if ( $0 == "#define _NFNETLINK_LOG_H" ) {
		print $0
		getline
		print $0
		print "#ifndef aligned_u64"
		print "#define aligned_u64 unsigned long long __attribute__((aligned(8)))"
		print "#endif"
	}

	print $0
	}' $TEMP > $TARGET
    else
    	echo "can't find nfnetlink_log.h kernel file in $INCLUDEDIR"
    	exit 1
    fi
}

[ "x$1" = "xdistrib" ] && include
autoreconf -fi
rm -Rf autom4te.cache
