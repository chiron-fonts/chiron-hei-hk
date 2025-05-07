#!/bin/bash

PADDINGS=(0 10)
WEIGHTS=(0 390 1000)
INT_WEIGHT=390

INSTANCE_WEIGHTS=(0 160 320 390 560 670 780 1000)
INSTANCE_PADDINGS=(0 6)
INSTANCE_BOLD_WEIGHT=780

declare -a PADDING_NAMES
PADDING_NAMES["0"]=
PADDING_NAMES["6"]=Text-

declare -a INSTANCE_NAMES
INSTANCE_FILENAMES["0"]=EL
INSTANCE_FILENAMES["160"]=L
INSTANCE_FILENAMES["320"]=N
INSTANCE_FILENAMES["390"]=R
INSTANCE_FILENAMES["560"]=M
INSTANCE_FILENAMES["670"]=SB
INSTANCE_FILENAMES["780"]=B
INSTANCE_FILENAMES["1000"]=H

build_vf_ufo() {
  STYLE=$1
  FILENAME=$2
  PADDING=$3
  WEIGHT=$4
  MASTER_FILENAME=${FILENAME}-padding${PADDING}_weight${WEIGHT}-Master
  DIR=$5
  DEST="$DIR/${MASTER_FILENAME}.ufo"

  if [ -d "$DEST" ]; then
    echo "[PADDING=${PADDING};WEIGHT=${WEIGHT}] UFOs for TTF build already exist: $DEST"
    return
  fi

  SRC="$DIR/${MASTER_FILENAME}.otf"
  if [ ! -f "$SRC" ]; then
    echo "[PADDING=${PADDING};WEIGHT=${WEIGHT}] Error: $SRC does not exist."
    exit 255
  fi

  CMD="tx -ufo $SRC $DEST"
  echo "[PADDING=${PADDING};WEIGHT=${WEIGHT}] Generating UFOs for TTF build: $CMD"
  $CMD
}

build_vf_otf() {
  STYLE=$1
  FILENAME=$2

  for PADDING in "${PADDINGS[@]}"
  do
    for WEIGHT in "${WEIGHTS[@]}"
    do
      DIR=padding${PADDING}_weight${WEIGHT}
      MASTER_FILENAME=${FILENAME}-padding${PADDING}_weight${WEIGHT}-Master
      if [[ $WEIGHT -eq $INT_WEIGHT ]]; then
        echo "[PADDING=${PADDING};WEIGHT=${WEIGHT}] (Intermediate) Building instance..."

        CMD="makeotf -nshw -f ./source/$STYLE/vf/masters/$DIR/cidfont.ps -ff ./source/$STYLE/vf/masters/$DIR/features.fea -fi ./source/$STYLE/vf/masters/$DIR/cidfontinfo -r -nS -cs 2 -ch ./source/$STYLE/common/cmap -ci ./source/$STYLE/common/sequences.txt -o /tmp/${MASTER_FILENAME}.otf"

        echo "[PADDING=${PADDING};WEIGHT=${WEIGHT}] $CMD"
        $CMD
      else
        echo "[PADDING=${PADDING};WEIGHT=${WEIGHT}] (Upstream) Building instance..."

        CMD="makeotf -nshw -f ./source/$STYLE/vf/masters/$DIR/cidfont.ps -ff ./source/$STYLE/vf/masters/$DIR/features.fea -fi ./source/$STYLE/vf/masters/$DIR/cidfontinfo -mf ./source/$STYLE/vf/FontMenuNameDB -r -nS -cs 2 -ch ./source/$STYLE/common/cmap -ci ./source/$STYLE/common/sequences.txt -o /tmp/${MASTER_FILENAME}.otf"

        echo "[PADDING=${PADDING};WEIGHT=${WEIGHT}] $CMD"
        $CMD
      fi
    done
  done

  for PADDING in "${PADDINGS[@]}"
  do
    for WEIGHT in "${WEIGHTS[@]}"
    do
      build_vf_ufo "$STYLE" "$FILENAME" "$PADDING" "$WEIGHT" /tmp
    done
  done
}

build_vf_gf() {
  mkdir -p $BUILD_GF_DIR
  FILENAME=$1
  REBUILD=$2

  OUTPUT="${FILENAME/VF/}"
  OUTPUT="${OUTPUT/It/-Italic}"

  if [ -z "$REBUILD" ]; then
    cp ./designspaces/$FILENAME.designspace /tmp/$FILENAME.designspace
    echo "Building OTF variable font..."
    buildcff2vf --omit-mac-names -d /tmp/$FILENAME.designspace -o /tmp/$FILENAME.otf
  fi

  CURRENT_DIR=$PWD
  cd /tmp || { echo "Failure"; exit 1; }

  sfntedit -x cmap=_tb_cmap,GDEF=_tb_GDEF,GPOS=_tb_GPOS,GSUB=_tb_GSUB /tmp/$FILENAME.otf
  sfntedit -a cmap=_tb_cmap,GDEF=_tb_GDEF,GPOS=_tb_GPOS,GSUB=_tb_GSUB /tmp/variable/$OUTPUT[PADG,wght].ttf

  python3 /tmp/gf_post.py $OUTPUT[PADG,wght].ttf

  ttx -m /tmp/$OUTPUT[wght].ttf /tmp/BASE.ttx -o /tmp/$OUTPUT[wght].ttf -f

  echo "Moving files to the target directory..."
  mv /tmp/$OUTPUT[wght].ttf $CURRENT_DIR/build/VAR_GF/
  
  cd $CURRENT_DIR || { echo "Failure"; exit 1; }
}


# Use the default BUILD_ROOT if not already defined
if [ -z "$BUILD_ROOT" ]; then
  BUILD_ROOT=./build
fi

BUILD_GF_DIR=$BUILD_ROOT/VAR_GF

cp ./scripts/build_var_ttf.py /tmp
cp ./scripts/gf_post.py /tmp
cp ./scripts/gf_notdef.py /tmp
cp ./scripts/config.yaml /tmp
cp ./scripts/BASE.ttx /tmp
cp ./designspaces/ChironHeiHK.designspace /tmp/
cp ./designspaces/ChironHeiHK-Italic.designspace /tmp/

build_vf_otf "regular" "ChironHeiHKVF" 
build_vf_otf "italic" "ChironHeiHKItVF"
python3 /tmp/gf_notdef.py 
echo "Building TTF variable fonts..."
gftools builder /tmp/config.yaml

build_vf_gf "ChironHeiHKVF"
build_vf_gf "ChironHeiHKItVF"