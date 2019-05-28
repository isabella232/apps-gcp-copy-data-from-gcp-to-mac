#!/bin/bash

COUNT=100

PATHFOLDER='/home/user/'
NAMEBIG_F="4MB"
NAMEMANYF="testdir"
DST_DIR='/Users/user/Desktop/test'

COMMNADS=(
"gcloud compute scp --zone=asia-northeast1-b --recurse test:${PATHFOLDER}${NAMEBIG_F} ${DST_DIR}"
"gcloud compute scp --zone=asia-northeast1-b --recurse test:${PATHFOLDER}${NAMEMANYF} ${DST_DIR}"
)

function writelog () {
  if [[ $(echo $@) =~ ^real\ ([0-9]+)m([0-9]+).([0-9]+)s.*$ ]]; then
    m=${BASH_REMATCH[1]}
    s=${BASH_REMATCH[2]}
    s=$(($m*60+$s))
    ms=${BASH_REMATCH[3]}
    echo ${s}.${ms}
    echo ${s}.${ms} >> log.txt
  fi
}

function fexec () {
  CMD="time($@) 2>&1"
  echo $CMD
  echo $CMD >> log.txt
  for j in `seq 1 $COUNT`
  do
    FULLRE=$(eval $CMD)
    # echo $FULLRE
    writelog $FULLRE
    rm -rf $DST_DIR
    mkdir $DST_DIR
  done
}

for ((i = 0; i < ${#COMMNADS[@]}; i++))
do
  CMD=${COMMNADS[$i]}
  DRUNCMD=$(echo ${CMD} | sed -e "s/scp/scp --dry-run/g")
  SCPCMD=$(eval ${DRUNCMD})
  RSYCMD=$(echo ${SCPCMD} | sed -e "s/.*-r/rsync -a -e \"ssh/g" | sed -e "s/ user@/\" user@/g")

  fexec $CMD
  sleep 1
  fexec $SCPCMD
  sleep 1
  fexec $RSYCMD
done


