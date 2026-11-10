# Exercise: The Greeting Card Maker

Exercise code for the lesson **Exercise: The Greeting Card Maker** in Bash in Depth on [ask-codey.com](https://www.ask-codey.com).

Finish a small application: `card.sh` makes a greeting card for the name you give it, asks for the greeting and who signs it, and saves the card under the person's name and today's date, numbered in order. Half of it is written for you, with the number-one bash bug in it. A check script runs your card maker for real and tells you which jobs are done.

## Before you start

You need a terminal (the Terminal app on a Mac, Ubuntu on Linux or in WSL on Windows) and **bats**, the tool that runs the check. If `bats --version` doesn't print a version yet, install it:

```bash
sudo apt install bats       # Ubuntu, and Ubuntu in WSL
brew install bats-core      # a Mac, with Homebrew
```

On Windows, unzip or clone this folder inside Ubuntu, in your Linux home folder (for example `~/terminal-practice/`), so `chmod` works on it.

## What's here

- `card.sh`: the card maker. It has an example done for you and six jobs, each a comment saying what to add or fix. For you to finish.
- `check.bats`: the check. You don't need to change it.

## Run it

Open a terminal in this folder, make the script runnable, and open it:

```bash
chmod +x card.sh
nano card.sh
```

Add a line or two under each job, save with Ctrl+O and Enter, and quit with Ctrl+X. Then run it and answer its two questions:

```bash
./card.sh Maya
cat cards/Maya-*.txt
```

Try a name with a space too, in quotes: `./card.sh "Aunt Rosa"`. Each run saves a new card in `cards/`; delete that folder whenever you want to start again.

## Check your work

From this folder:

```bash
bats check.bats
```

At first most checks fail: that is expected. Each job you finish turns its check into a ✓. A failing check's message says which job it is and gives a hint. The check runs a copy of your script in a throwaway folder and types the answers for it, so your own `cards` folder isn't touched.

## The rules

- Keep the variable names the jobs give (`name`, `greeting`, `from`, `today`, `number`): the lines in job 6 use them.
- Ask the questions in the order the jobs give: the greeting first, then who signs it.
- Don't write today's date or the card's number in by hand: work them out with `$( )` and `$(( ))`.

## Tips

- `$1` is the first word typed after the script's name.
- `read -r -p "Question: " answer` asks a question and keeps the answer in `answer`.
- `${greeting:-Happy birthday}` is `greeting`'s value, or `Happy birthday` when it's empty.
- `date +%F` prints today's date as year-month-day.
- Put double quotes around every `$`, including after `>` and `>>`.

## Hand it in

When it works, push your solution to a public repo of your own on GitHub, then paste that repo's address into **Submit your exercise** on the lesson page at [ask-codey.com](https://www.ask-codey.com). That's what completes the lesson. The lesson page shows the Git commands, step by step.
