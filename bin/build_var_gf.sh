#!/bin/bash

. $(dirname "$0")/profile

mkdir -p /source/fonts/OTF
build_vf_otf "regular" "ChironHeiHKVF" "/source/fonts/OTF/ChironHeiHK[SPAC,wght].otf"
build_vf_otf "italic" "ChironHeiHKItVF" "/source/fonts/OTF/ChironHeiHKIt[SPAC,wght].otf"
