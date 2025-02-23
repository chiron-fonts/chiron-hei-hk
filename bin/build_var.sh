#!/bin/bash

. $(dirname "$0")/profile

build_vf_otf() {
  mkdir -p $BUILD_VF_DIR

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

  echo "Building OTF variable font..."
  cp ./designspaces/$FILENAME.designspace /tmp/$FILENAME.designspace
  buildcff2vf --omit-mac-names -d /tmp/$FILENAME.designspace -o /tmp/$FILENAME.otf

  # We still need the built otf in /tmp for use by build_vf_ttf()
  echo "Moving files to the target directory..."
  cp /tmp/$FILENAME.otf $BUILD_VF_DIR
}

build_vf_ttf() {
  STYLE=$1
  FILENAME=$2
  for PADDING in "${PADDINGS[@]}"
  do
    for WEIGHT in "${WEIGHTS[@]}"
    do
      build_vf_ufo "$STYLE" "$FILENAME" "$PADDING" "$WEIGHT" /tmp
    done
  done

  cp ./scripts/build_var_ttf.py /tmp

  CURRENT_DIR=$PWD
  cd /tmp || { echo "Failure"; exit 1; }

  echo $FILENAME
  echo "Building TTF variable font..."
  python3 ./build_var_ttf.py /tmp/$FILENAME.designspace /tmp/$FILENAME.ttf

  echo "Post-processing TTF font..."
  sfntedit -x cmap=_tb_cmap,GDEF=_tb_GDEF,GPOS=_tb_GPOS,GSUB=_tb_GSUB,name=_tb_name,OS/2=_tb_OS2,hhea=_tb_hhea,post=_tb_post,STAT=_tb_STAT,fvar=_tb_fvar ./ChironHeiHKVF.otf
  sfntedit -a cmap=_tb_cmap,GDEF=_tb_GDEF,GPOS=_tb_GPOS,GSUB=_tb_GSUB,name=_tb_name,OS/2=_tb_OS2,hhea=_tb_hhea,post=_tb_post,STAT=_tb_STAT,fvar=_tb_fvar ./ChironHeiHKVF.ttf

  echo "Moving files to the target directory..."
  mv /tmp/$FILENAME.ttf $BUILD_VF_DIR

  cd $CURRENT_DIR || { echo "Failure"; exit 1; }
}

build_vf_otf "regular" "ChironHeiHKVF"
build_vf_ttf "regular" "ChironHeiHKVF"

build_vf_otf "italic" "ChironHeiHKItVF"
build_vf_ttf "italic" "ChironHeiHKItVF"
