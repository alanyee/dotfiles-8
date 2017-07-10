#!/usr/bin/env bash

# barInfo example:
barInfo="$p_format"

# vanilla/theme intention for all targets:
vanilla() {
  case $1 in
    fg) echo "$p_fg_inactive" ;;
    bg) echo "$p_bg_inactive" ;;
    activefg) echo "$p_fg_active" ;;
    activebg) echo "$p_bg_active" ;;
    line) echo "$p_bg_inactive" ;;
    activeline) echo "$p_bg_active" ;;
    prefix) echo "";;
    suffix) echo "";;
  esac
}

# step will be per section, total will be largest section.
separateStep() {
  step_type="separate"
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
      [ "$i" = "0" ] && eval ${lemon}_align=left
      [ "$i" = "1" ] && eval ${lemon}_align=center
      [ "$i" = "2" ] && eval ${lemon}_align=right

      eval $lemon=$j
      [ "$i" = "0" ] && j=$((j-1)) || j=$((j+1))
    done
    i=$((i+1))
  done
  IFS=
}

# step will be across all sections, total will be number of lemons
togetherStep() {
  step_type="together"
  total=$(echo $barInfo | tr ':|' ' '| wc -w)

  # set step
  IFS=\|:
  j=0
  for lemon in $barInfo; do
      eval $lemon=$j
      j=$((j+1))
  done
  IFS=

  # set align
  IFS=\|
  i=0
  for section in $barInfo; do
      IFS=':'
      for lemon in $section; do
          [ "$i" = "0" ] && eval ${lemon}_align=left
          [ "$i" = "1" ] && eval ${lemon}_align=center
          [ "$i" = "2" ] && eval ${lemon}_align=right
      done
      i=$((i+1))
  done
  IFS=
}

# reverse the steps by total
reverseSteps() {
  # by lemon
  IFS=' '
  for lemon in $lemons; do
    temp=$(eval "echo \${$lemon}")
    temp=$((temp+1))
    eval $lemon=$((total-temp))

    lemon_align="$(eval "echo \${${lemon}_align}")"
    case $lemon_align in
        left) eval ${lemon}_align=right ;;
        right) eval ${lemon}_align=left ;;
    esac
  done
  IFS=
}

# get gradient by step, use total as step.
gradientGet() {
  step=$((step+1))
  gradient $color0 $color7 $total | sed -n ${step}p
}


# keep these dynamic unless otherwise,
# because the fg color peek is neat and saves time.
# means we need default bg activebg as well...
if [ ! "$(type -t fg)" = "function" ]; then
  fg() {
    colort -c "$(bg)" && check="$p_bg_normal" || check="$p_fg_normal"
    colort -c "$check" && echo $p_fg_normal || echo $p_bg_normal
  }
fi

if [ ! "$(type -t activefg)" = "function" ]; then
  activefg() {
    colort -c "$(activebg)" && check="$p_bg_active" || check="$p_fg_active"
    colort -c "$check" && echo $p_fg_active || echo $p_bg_active
  }
fi

if [ ! "$(type -t bg)" = "function" ]; then
    bg() {
        vanilla bg
    }
fi

if [ ! "$(type -t activebg)" = "function" ]; then
    activebg() {
        vanilla activebg
    }
fi

if [ ! "$(type -t stepSetup)" = "function" ]; then
    stepSetup() {
        separateStep
        reverseSteps
    }
fi

stepSetup