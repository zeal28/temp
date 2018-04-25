#!/bin/sh

# creates target mirrors under /tmp and symlinks them back into directories having pom.xml.

TMP=/tmp/.mvn-target-dirs.$USER

if [ $# == 0 ]; then
    dirs=.
else
    dirs="$@"
fi

for dir in $dirs; do
    find $dir -type f -name pom.xml | while read POM; do
        SRC_DIR=$(cd "`dirname "$POM"`"; pwd)
        ABS_DIR=${SRC_DIR#/}
        if [ ! -e "$SRC_DIR/target" ]; then
            rm -rf "$TMP/$ABS_DIR/target" 2>/dev/null
            mkdir -p "$TMP/$ABS_DIR/target"
            echo "ln -s \"$TMP/$ABS_DIR/target\" \"$SRC_DIR\""
            ln -s "$TMP/$ABS_DIR/target" "$SRC_DIR"
        fi
    done
done
