#!/usr/bin/env bash
set -euo pipefail

BB_JDE_HOME="${BB_JDE_HOME:-/opt/rim/jde-7.1.0}"
RAPC_JAR="${BB_JDE_HOME}/bin/rapc.jar"
NET_RIM_API="${BB_JDE_HOME}/lib/net_rim_api.jar"

if [[ ! -f "${RAPC_JAR}" ]] || [[ ! -f "${NET_RIM_API}" ]]; then
    echo "[-] ERROR: BlackBerry JDE not found at: ${BB_JDE_HOME}"
    exit 1
fi

rm -rf build bin dist
mkdir -p build/classes bin dist

echo "==> Step 1: Compiling Java ME CLDC 1.1 Sources..."
javac -source 1.3 -target 1.3 -nowarn \
      -bootclasspath "${NET_RIM_API}" \
      -d build/classes \
      src/com/javaboychimera/ui/RomMenuEntry.java \
      src/com/javaboychimera/ui/InputDeviceBridge.java \
      src/com/javaboychimera/ui/RomSelectorScreen.java \
      src/com/javaboychimera/platform/FileSystemScanner.java \
      src/com/javaboychimera/JavaBoyChimeraMIDlet.java

echo "==> Step 2: Running RAPC Bytecode Compiler & COD Packaging..."
java -jar "${RAPC_JAR}" \
     import="${NET_RIM_API}" \
     codename=bin/JavaBoyChimera \
     JavaBoyChimera.rapc \
     build/classes

cp JavaBoyChimera.alx bin/
(cd bin && zip -q "../dist/JavaBoyChimera_v0.1.0.zip" JavaBoyChimera.cod JavaBoyChimera.jad JavaBoyChimera.jar JavaBoyChimera.alx)

echo "==> Build Succeeded!"
ls -lh dist/
