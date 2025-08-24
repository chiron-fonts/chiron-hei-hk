#!/bin/bash

. $(dirname "$0")/profile

build_vf_woff2() {
  STYLE=$1
  SOURCE_FILENAME=$2
  OUTPUT_DIRECTORY=$3
  ASSET_FILENAME=$4

  echo "[WOFF2] Style: $STYLE, Source: $SOURCE_FILENAME, Output: $OUTPUT_DIRECTORY, Asset: $ASSET_FILENAME"

  mkdir -p "$OUTPUT_DIRECTORY/css" "$OUTPUT_DIRECTORY/demo" "$OUTPUT_DIRECTORY/woff2"

  cp ./source/$STYLE/woff2/$ASSET_FILENAME.css "$OUTPUT_DIRECTORY/css/$ASSET_FILENAME.css"
  cp ./source/$STYLE/woff2/$ASSET_FILENAME.html "$OUTPUT_DIRECTORY/demo/$ASSET_FILENAME.html"

  while IFS=, read -r pfx codepoints
  do
      echo "Building WOFF2 for $pfx"
      mkdir -p "$OUTPUT_DIRECTORY/woff2/$(dirname "$pfx")"
      pyftsubset "$SOURCE_FILENAME" --unicodes="$codepoints" --flavor=woff2 --layout-features=* --drop-tables="BASE" --output-file="$OUTPUT_DIRECTORY/woff2/$pfx.woff2"
  done < <(grep "" ./source/$STYLE/woff2/subset.csv)
}

build_vf_woff2 "regular" "$BUILD_VF_DIR/ChironHeiHKVF.otf" $BUILD_WOFF2_OTF_DIR "vf"
build_vf_woff2 "regular" "$BUILD_VF_DIR/ChironHeiHKVF.ttf" $BUILD_WOFF2_TTF_DIR "vf"

build_vf_woff2 "italic" "$BUILD_VF_DIR/ChironHeiHKItVF.otf" $BUILD_WOFF2_OTF_DIR "vf-italic"
build_vf_woff2 "italic" "$BUILD_VF_DIR/ChironHeiHKItVF.ttf" $BUILD_WOFF2_TTF_DIR "vf-italic"
