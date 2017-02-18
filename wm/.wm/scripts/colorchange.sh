#!/usr/bin/env dash
# override theme intentions in a generative fashion.
# takes 2 arguments, the lemon and the target.
# target may be one of: bg, fg, activefg, activebg, line, activeline
# theme variables are exposed here to use and reference.

lemon="$1"
target="$2"

# barInfo example:
# dropdown:desktop|title|clock

# vanilla/theme intention for all targets:

vanilla() {
  [ ! -z "$1" ] && target="$1"
  case $target in
    fg) echo -n "$pFGInactiveTab" ;;
    bg) echo -n "$pBGInactiveTab" ;;
    activefg) echo -n "$pFGActiveTab" ;;
    activebg) echo -n "$pBGActiveTab" ;;
    line) echo -n "$pBGInactiveTab" ;;
    activeline) echo -n "$pBGActiveTab" ;;
  esac
}

# ignore lemons not included.
if ! echo $barInfo | grep -q $lemon; then
  vanilla
  exit
fi

# step will be per section, total will be largest section.
separateStep() {
  IFS=\|
  total=0
  for section in $barInfo; do
    temptotal=$(echo $section | tr ':' ' '| wc -w)
    [ $temptotal -gt $total ] && total=$temptotal
  done

  IFS=\|
  i=0
  for section in $barInfo; do
    # reverse count on left
    [ "$i" = "0" ] && j=$((total-1)) || j=0

    IFS=':'
    for lemon in $section; do
      eval $lemon=$j
      [ "$i" = "0" ] && j=$((j-1)) || j=$((j+1))
    done
    i=$((i+1))
  done
  IFS=
}

# step will be across all sections, total will be number of lemons
togetherStep() {
  total=$(echo $barInfo | tr ':|' ' '| wc -w)

  IFS=\|:
  j=0
  for lemon in $barInfo; do
      eval $lemon=$j
      j=$((j+1))
  done
  IFS=
}

# reverse the steps by total
reverseSteps() {
  # by lemon
  lemons=$(echo $barInfo | tr '|:' ' ')
  IFS=' '
  for lemon in $lemons; do
    temp=$(eval "echo \${$lemon}")
    eval $lemon=$((total-temp))
  done
  IFS=
}

# get gradient by step, use total as step.
gradientGet() {
  # 1-indexed, skip the first gradient step as it's the color itself.
  step=$((step+2))
  echo -n "$(gradient $color0 $color7 $total | sed -n ${step}p)"
}


# options
#separateStep
togetherStep
#reverseSteps

step="$(eval "echo \${${1}"})"

# use lemon step and target to make decisions here:
# still playing around..
bg() {
  # select a color in the scheme
  vanilla bg
  #step=$((step+1))
  #step=$((step*2))
  #eval "echo -n \#\${color${step}}"
  #gradientGet
}

activebg() {
  base=$(bg)

  #step=$((step+1))
  #eval "echo -n \#\${color${step}}"
  gradientGet

  # allow either direction for light and dark themes.
  #colort -l 30 "$base" || colort -30 "$base"
}

fg() {
  if colort -c "$(bg)" && colort -c "$pBG"; then
    echo -n $pFG
  else
    echo -n $pBG
  fi
}

activefg() {
  if colort -c "$(activebg)" && colort -c "$pBGActiveTab"; then
    echo -n $pFG
  else
    echo -n $pBG
  fi
}

line() {
  step=$((step+1))
  eval "echo -n \#\${color${step}}"
}

activeline() {
    vanilla activeline
}

eval $target
