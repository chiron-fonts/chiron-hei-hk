#!/bin/bash

. "$(dirname "$0")/profile"

build_static_otf() {
  STYLE=$1
  PREFIX=$2

  echo "[STATIC OTF] Style: $STYLE"
  echo "[STATIC OTF] Target OTF directory: $BUILD_STATIC_OTF_DIR"
  echo "[STATIC OTF] Target TTF directory: $BUILD_STATIC_TTF_DIR"

  mkdir -p "$BUILD_STATIC_OTF_DIR"
  mkdir -p "$BUILD_STATIC_TTF_DIR"

  for PADDING in "${INSTANCE_PADDINGS[@]}"
  do
    for WEIGHT in "${INSTANCE_WEIGHTS[@]}"
    do
      DIR=padding${PADDING}_weight${WEIGHT}

      FLAG_BOLD=""
      if [[ $WEIGHT -eq $INSTANCE_BOLD_WEIGHT ]]; then
        FLAG_BOLD="-b"
      fi

      FLAG_ITALIC=""
      FILENAME_SUFFIX=""
      if [[ $STYLE = "italic" ]]; then
        FLAG_ITALIC="-i"
        FILENAME_SUFFIX="-It"
      fi

      FILENAME="${PREFIX}-${PADDING_NAMES[$PADDING]}${INSTANCE_FILENAMES[$WEIGHT]}${FILENAME_SUFFIX}"

      CMD="makeotf -nshw -f ./source/$STYLE/static/masters/$DIR/cidfont.ps $FLAG_BOLD $FLAG_ITALIC -ff ./source/$STYLE/static/masters/$DIR/features.fea -fi ./source/$STYLE/static/masters/$DIR/cidfontinfo -mf ./source/$STYLE/static/FontMenuNameDB -r -cs 2 -ch ./source/$STYLE/common/cmap -ci ./source/$STYLE/common/sequences.txt -o /tmp/${FILENAME}.otf"
      echo "[STATIC OTF] (W=$WEIGHT,P=$PADDING) Building OTF: $CMD"
      $CMD

      CMD="otf2ttf /tmp/${FILENAME}.otf /tmp/${FILENAME}.ttf"
      echo "[STATIC OTF] (W=$WEIGHT,P=$PADDING) Converting OTF to TTF: $CMD"
      $CMD

      echo "[STATIC OTF] Moving files to target directories..."
      mv "/tmp/${FILENAME}.otf" "$BUILD_STATIC_OTF_DIR"
      mv "/tmp/${FILENAME}.ttf" "$BUILD_STATIC_TTF_DIR"
    done
  done
}

build_static_otf "regular" "ChironHeiHK"
build_static_otf "italic" "ChironHeiHK"