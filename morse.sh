#!/bin/bash
# converted from https://gist.github.com/mwgamera/4654709

# config
wpm=18
freq=750				# set bandpass to 1
#freq='1000 sine 2000 channels 1'	# set bandpass to 0
bandpass=1
gain=-1

# use dc or bc
if hash dc 2>/dev/null; then
  math=dc
elif hash bc 2>/dev/null; then
  math=bc
else
  echo "Please install either dc or bc packages" >&2
  echo
  exit 1
fi

# lengths
usedc() {
  u1=$(dc <<< "$wpm 9k1.200r/p")
  u3=$(dc <<< "$u1 3*p")
  #u7=$(dc <<< "$u1 7*p")
  u7=$(dc <<< "$u1 4*p")
  bw=$(dc <<< "$u1 9k1r/7*p")
}
usebc() {
  u1=$(bc <<< "scale=9;1.2/$wpm")
  u3=$(bc <<< "scale=9;$u1*3")
  #u7=$(bc <<< "scale=9;$u1*7")
  u7=$(bc <<< "scale=9;$u1*4")
  bw=$(bc <<< "scale=9;1/$u1*7")
}
use$math

# synth
if [ $bandpass -eq 1 ]; then
  # single freq
  sox -n dit.wav synth $u1 sine $freq gain $gain bandpass $freq $bw
  sox -n dah.wav synth $u3 sine $freq gain $gain bandpass $freq $bw
else
  # multi freq
  sox -n dit.wav synth $u1 sine $freq gain $gain
  sox -n dah.wav synth $u3 sine $freq gain $gain
fi
# silence
sox -n spi.wav trim 0 $u1
sox -n spl.wav trim 0 $u3
sox -n spw.wav trim 0 $u7

towav() {
  out=
  for (( i=0; i<${#2}; i++ )); do
    if [ $[i+1] -eq ${#2} ]; then
      sp=spl
    else
      sp=spi
    fi
    if [ ${2:$i:1} = '.' ]; then
      char='dit'
    else
      char='dah'
    fi
    out="$out $char.wav $sp.wav"
  done
  sox $out $1.wav
}

# standard numbers
towav 1 .----
towav 2 ..---
towav 3 ...--
towav 4 ....-
towav 5 .....
towav 6 -....
towav 7 --...
towav 8 ---..
towav 9 ----.
towav 0 -----
# -ish
towav T -

# cut numbers
#towav 1 .-	# A
#towav 2 -.	# N
#towav 3 -..	# D
#towav 4 ..-	# U
#towav 5 .--	# W
#towav 6 .-.	# R
#towav 7 ..	# I
#towav 8 --.	# G
#towav 9 --	# M
#towav 0 -	# T

# prosigns
# use lower case to avoid collisions with letters
towav b -...-	# BT
#towav a .-.-.	# AR
#towav d -..-.	# DN, /

# clean up
rm dit.wav dah.wav spi.wav spl.wav

#echo "sox in.wav out.mp3 bandpass $freq $bw"
echo "sox \`cat V2.list\` V2.mp3 bandpass $freq $bw"
