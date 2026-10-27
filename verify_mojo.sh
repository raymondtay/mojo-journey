#!/bin/bash
echo "Starting Mojo verification..." > verify_mojo.log
files=$(find . -name "*.mojo" -not -path "*/.pixi/*")
for f in $files; do
    echo "Running $f..." >> verify_mojo.log
    pixi run mojo "$f" >> verify_mojo.log 2>&1
    if [ $? -ne 0 ]; then
        echo "FAILED $f" >> verify_mojo.log
    else
        echo "PASSED $f" >> verify_mojo.log
    fi
    echo "-------------------" >> verify_mojo.log
done
echo "Verification complete." >> verify_mojo.log
