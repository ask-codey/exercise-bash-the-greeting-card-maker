#!/usr/bin/env bats
# Checks your card maker (card.sh) by running it for real.
# Each check copies card.sh into a throwaway folder, runs it there with a name as its argument,
# types the answers to its questions through a pipe, and reads the card it saved. Nothing in
# this folder is changed, and your own cards folder is never touched.
# Run it from this folder with:  bats check.bats
# You don't need to change this file.

setup() {
  cd "$BATS_TEST_DIRNAME"
  script="$BATS_TEST_DIRNAME/card.sh"
  dir="$BATS_TEST_TMPDIR/shop"
  mkdir -p "$dir"
  [[ -f "$script" ]] && cp "$script" "$dir/card.sh"
  today="$(date +%F)"
}

# Runs card.sh in the throwaway folder. The first argument is the answers to its questions,
# one per line; the rest are the script's own arguments.
make_card() {
  local answers="$1"
  shift
  (cd "$dir" && printf '%s' "$answers" | bash ./card.sh "$@") 2>&1
}

# The one card in the throwaway cards folder, or nothing when there isn't exactly one.
the_card() {
  local cards=("$dir"/cards/*)
  if [[ ${#cards[@]} -eq 1 && -f "${cards[0]}" ]]; then
    printf '%s' "${cards[0]}"
  fi
}

# Line N of the one card.
card_line() {
  sed -n "${1}p" "$(the_card)"
}

# Fails with a message when no single card was saved.
need_card() {
  if [[ -z "$(the_card)" ]]; then
    echo "card.sh didn't save one card in the cards folder. What it printed:"
    echo "$output" | head -n 3
    echo "Check that the lines in job 6 still write to \$file."
    return 1
  fi
}

@test "card.sh is here, and bash can read it" {
  if [[ ! -f "$script" ]]; then
    echo "card.sh is missing. Download the exercise again to get it back."
    return 1
  fi
  if ! errors="$(bash -n "$script" 2>&1)"; then
    echo "bash can't read card.sh. Its first error:"
    echo "$errors" | head -n 1
    echo "Look at the line it names: a quote that's opened and never closed is the usual cause."
    return 1
  fi
}

@test "1) the card is for the name given as the first argument" {
  output="$(make_card $'\nSam\n' Maya)"
  need_card
  if [[ "$(card_line 1)" != "Dear Maya," ]]; then
    echo "./card.sh Maya should write a card that starts \"Dear Maya,\", but it starts: $(card_line 1)"
    echo "Job 1: the first argument typed after the script's name is \$1. Keep it in name, with name=\"\$1\"."
    return 1
  fi
}

@test "2) the greeting is asked for, with Happy birthday when the answer is empty" {
  if ! grep -qE '^[^#]*read .*greeting' "$script"; then
    echo "card.sh doesn't ask for the greeting yet. Job 2: read -r -p \"Greeting [Happy birthday]: \" greeting"
    return 1
  fi
  output="$(make_card $'Thank you\nSam\n' Maya)"
  need_card
  if [[ "$(card_line 3)" != "Thank you!" ]]; then
    echo "Answering \"Thank you\" should give the card the line \"Thank you!\", but its third line is: $(card_line 3)"
    echo "Job 2: read keeps the answer in the variable named at the end of the line, greeting."
    return 1
  fi
  rm -rf "$dir/cards"
  output="$(make_card $'\nSam\n' Maya)"
  if [[ "$(card_line 3)" != "Happy birthday!" ]]; then
    echo "Pressing Enter at the greeting should give \"Happy birthday!\", but the third line is: $(card_line 3)"
    echo "Job 2: after the read, greeting=\"\${greeting:-Happy birthday}\" fills in the default when the answer is empty."
    return 1
  fi
}

@test "3) the card is signed with the second answer" {
  if ! grep -qE '^[^#]*read .*from' "$script"; then
    echo "card.sh doesn't ask who signs the card yet. Job 3: read -r -p \"Signed by: \" from"
    return 1
  fi
  output="$(make_card $'\nDiego\n' Maya)"
  need_card
  if [[ "$(card_line 5)" != "From Diego" ]]; then
    echo "Answering \"Diego\" at \"Signed by: \" should give the line \"From Diego\", but the fifth line is: $(card_line 5)"
    return 1
  fi
}

@test "4) the card is named and dated with today's date" {
  if ! grep -qE '^[^#]*\$\( *date' "$script"; then
    echo "card.sh doesn't get today's date from date yet. Job 4: today=\"\$(date +%F)\""
    return 1
  fi
  output="$(make_card $'\nSam\n' Maya)"
  need_card
  if [[ "$(basename "$(the_card)")" != "Maya-$today.txt" ]]; then
    echo "The card should be saved as cards/Maya-$today.txt, but it's: $(the_card | sed "s|$dir/||")"
    echo "Job 4: date +%F prints the date as year-month-day, such as 2026-11-09."
    return 1
  fi
  if [[ "$(card_line 6)" != *"made on $today" ]]; then
    echo "The card's last line should end with \"made on $today\", but it is: $(card_line 6)"
    return 1
  fi
}

@test "5) every card gets the next number" {
  if ! grep -qE '^[^#]*\$\(\(' "$script"; then
    echo "card.sh doesn't work out the card's number yet. Job 5: number=\$(( \$(ls cards | wc -l) + 1 ))"
    return 1
  fi
  output="$(make_card $'\nSam\n' Maya)"
  need_card
  if [[ "$(card_line 6)" != "Card 1, made on "* ]]; then
    echo "The first card in an empty cards folder should be card 1, but its last line is: $(card_line 6)"
    echo "Job 5: count the cards already there with \$(ls cards | wc -l), then add 1 inside \$(( ))."
    return 1
  fi
  make_card $'\nSam\n' Diego > /dev/null
  second="$(sed -n 6p "$dir/cards/Diego-$today.txt" 2>/dev/null)"
  if [[ "$second" != "Card 2, made on "* ]]; then
    echo "With one card already in the folder, the next should be card 2, but its last line is: $second"
    echo "Job 5: the number must come from the cards folder each time, not be written in by hand."
    return 1
  fi
}

@test "6) a name with a space comes out exactly as typed" {
  output="$(make_card $'\nSam\n' "Aunt Rosa")"
  if [[ ! -f "$dir/cards/Aunt Rosa-$today.txt" ]]; then
    echo "./card.sh \"Aunt Rosa\" should save cards/Aunt Rosa-$today.txt, but it printed:"
    echo "$output" | head -n 2
    echo "Job 6: the shell split the name at its space. Put double quotes around every \$file and every line that uses a \$, as in > \"\$file\"."
    return 1
  fi
  if [[ "$(sed -n 1p "$dir/cards/Aunt Rosa-$today.txt")" != "Dear Aunt Rosa," ]]; then
    echo "The card for Aunt Rosa should start \"Dear Aunt Rosa,\", but it starts: $(sed -n 1p "$dir/cards/Aunt Rosa-$today.txt")"
    return 1
  fi
}

@test "6) a greeting with a * and two spaces comes out exactly as typed" {
  output="$(make_card $'Thanks a million  *  from all of us\nSam  and  Diego\n' Maya)"
  need_card
  if [[ "$(card_line 3)" != "Thanks a million  *  from all of us!" ]]; then
    echo "The greeting \"Thanks a million  *  from all of us\" (two spaces each side of the *) came out as:"
    echo "$(card_line 3)"
    echo "Job 6: without double quotes, the shell turns a * into file names and squeezes spaces. Write echo \"\$greeting!\"."
    return 1
  fi
  if [[ "$(card_line 5)" != "From Sam  and  Diego" ]]; then
    echo "Signed \"Sam  and  Diego\" (two spaces each), the card says: $(card_line 5)"
    echo "Job 6: put the whole line in double quotes: echo \"From \$from\"."
    return 1
  fi
}

@test "6) it says which card it saved" {
  output="$(make_card $'\nSam\n' "Aunt Rosa")"
  last="$(printf '%s\n' "$output" | tail -n 1)"
  if [[ "$last" != "Card 1 saved: cards/Aunt Rosa-$today.txt" ]]; then
    echo "The last line card.sh prints should be \"Card 1 saved: cards/Aunt Rosa-$today.txt\", but it's: $last"
    return 1
  fi
}
