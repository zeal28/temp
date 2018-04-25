#!/bin/bash
# 
# A stock mac will need to have java installed from oracle
#    see the output from /usr/libexec/java_home

function errorAbort() {
	echo "Error!"
	exit 1
}

DEBUG=/usr/bin/false

##samishai 11/11/2010
##Support environments with predefined VIEW variable. Specifically to support new development environemtn MAC OS.

if [ ! -n "$VIEW" ]; then
	if [ "$OSTYPE" == "cygwin" ]; then
		VIEW=`pwd | cut -d/ -f1-5`
	else
		if [[ "$OSTYPE" == darwin* ]]; then
                        pushd $(dirname $0)
                        SCRIPTPATH=$(pwd -P)
			popd
                        NEWPATH=${SCRIPTPATH}/../../
                        pushd "${NEWPATH}"
                        VIEW=$(pwd)
                        popd
			export JAVA_HOME=$(/usr/libexec/java_home)
		else
			SCRIPT=$(readlink -f $0)
			SCRIPTPATH=$(dirname $SCRIPT)
			pushd ${SCRIPTPATH}/../../
			#VIEW=/vob
			VIEW=$(pwd)
			popd
		fi
	fi
fi

export VIEW

if [ ! -e "${VIEW}" ]; then 
	echo "Cannot find VIEW ${VIEW}"
	exit 1
fi

if [ ! -e "${VIEW}" ]; then
	echo "Cannot find DIR ${VIEW}!"
	exit 1
fi

# On Cisco Linux boxes, we have small quotas for our network home directories,
# so we symlink everything to /tmp.  But the custom plugin that does this
# mapping fails if the /tmp/.m2-${USER} folder is missing.
if [ ! -e "/tmp/.m2-${USER}" ]; then
	mkdir "/tmp/.m2-${USER}"
fi

if [ $DEBUG ]; then
	echo
	echo "CWD        = $PWD"
	echo "VIEW       = $VIEW"
	echo "M2_HOME    = $M2_HOME"
	echo "JAVA_HOME  = $JAVA_HOME"
	echo
fi

# Install all boostrap and parent POM files into the local repository
# But don't install the nightly POMs, however, because they override/
# overwrite the non-nightly POMs.
#
for POM in \
		"${VIEW}/s3_tools/maven/bootstrap-s3-pom.xml"       \
		"${VIEW}/s3_tools/maven/bootstrap-ipics-pom.xml"    \
		"${VIEW}/s3_tools/maven/bootstrap-crs-ippe-pom.xml" \
		"${VIEW}/s3/poms/parent-s3-pom.xml"                 \
		"${VIEW}/s3/poms/parent-ipics-pom.xml"              \
		"${VIEW}/s3/poms/parent-ippe-pom.xml"               \
	; do
		echo
		if [ -e "${POM}" ]; then
			if [ "$OSTYPE" == "cygwin" ]; then
				# mvn doesn't like the '/cygdrive/c' prefix when we pass in the POM file 
				p=/`echo $POM | cut -d/ -f4-`
				POM=$p
			fi
			if [ $DEBUG ]; then
				echo "$POM"
			fi
			"${VIEW}/s3_tools/bin/mvn" -f "$POM" install || errorAbort
		else
			echo "Cannot find POM $f"
		fi
done

echo "Make a default settings.xml so m2eclipse doesn't complain so much..."
if [ ! -e "$HOME/.m2" ]; then
	mkdir "$HOME/.m2"
fi
if [ ! -e "$HOME/.m2/settings.xml" ]; then
	echo '<?xml version="1.0" encoding="UTF-8"?><settings xsi:schemaLocation="http://maven.apache.org/xsd/settings-1.0.0.xsd"></settings>' >  "$HOME/.m2/settings.xml"
fi

echo "Done!"
