#!/bin/bash

. $(dirname "$0")/profile

build_vf_otf "regular" "ChironHeiHKVF"
build_vf_ttf "regular" "ChironHeiHKVF"

build_vf_otf "italic" "ChironHeiHKItVF"
build_vf_ttf "italic" "ChironHeiHKItVF"
