#!/usr/bin/env bash
set -euo pipefail

BB_JDE_HOME="${BB_JDE_HOME:-/opt/rim/jde-7.1.0}"
RAPC_JAR="${BB_JDE_HOME}/bin/rapc.jar"
NET_RIM_API="${BB_JDE_HOME}/lib/net_rim_api.jar"

if [[ ! -f "${RAPC_JAR}" ]] || [[ ! -f "${NET_RIM_API}" ]]; then
    echo "[-] ERROR: BlackBerry JDE components not found in: ${BB_JDE_HOME}"
    exit 1
fi

rm -rf build bin dist
mkdir -p build/classes bin dist

echo "==> Step 1: Compiling Java ME MMAPI Sources..."
javac -source 1.3 -target 1.3 -nowarn \
      -bootclasspath "${NET_RIM_API}" \
      -d build/classes \
      src/com/chimeratube/pearl3g/Pearl3GChimeraTubeMIDlet.java \
      src/com/chimeratube/pearl3g/MainFeedScreen.java \
      src/com/chimeratube/pearl3g/VideoPlaybackScreen.java

echo "==> Step 2: Executing RAPC Bytecode Compiler..."
java -jar "${RAPC_JAR}" \
     import="${NET_RIM_API}" \
     codename=bin/ChimeraTube_Pearl9105 \
     ChimeraTube_Pearl9105.rapc \
     build/classes

cp ChimeraTube_Pearl9105.alx bin/
(cd bin && zip -q "../dist/ChimeraTube_Pearl9105_v3.0.0.zip" ChimeraTube_Pearl9105.cod ChimeraTube_Pearl9105.jad ChimeraTube_Pearl9105.jar ChimeraTube_Pearl9105.alx)

echo "==> Build Succeeded for ChimeraTube!"
ls -lh dist/
