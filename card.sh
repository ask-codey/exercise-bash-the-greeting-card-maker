#!/usr/bin/env bash
# The Greeting Card Maker
# Makes a greeting card for the name you give it, and saves it in the cards folder.
# Run it as:  ./card.sh Maya
# A name with a space goes in quotes:  ./card.sh "Aunt Rosa"
#
# Six jobs below, each a comment saying what to add. The example is done for you.

# Example: make the folder the cards go in (-p: no error when it's already there).
mkdir -p cards

# 1. Keep the first argument, the person the card is for, in a variable called name.


# 2. Ask "Greeting [Happy birthday]: " with read -r -p, and keep the answer in greeting.
#    When the answer is empty, greeting becomes Happy birthday.


# 3. Ask "Signed by: " with read -r -p, and keep the answer in from.


# 4. Keep today's date, such as 2026-11-09, in a variable called today. Use $( ) and date.


# 5. Work out the card's number, one more than the number of cards already in the cards
#    folder, and keep it in a variable called number. Use $(( )), with $(ls cards | wc -l) inside.


# 6. These lines write the card and say where it went, and they have the number-one bash bug.
#    Fix every line, so a name with a space ("Aunt Rosa"), or a greeting with a * or two
#    spaces in a row, comes out exactly as it was typed.
file=cards/$name-$today.txt
echo Dear $name, > $file
echo >> $file
echo $greeting! >> $file
echo >> $file
echo From $from >> $file
echo Card $number, made on $today >> $file
echo Card $number saved: $file
