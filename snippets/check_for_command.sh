#!/bin/bash
#
# How to check if a command is accessible.  This will work even with '-e' option
# turned on
#


set -e
set -u


# Command is a bash builtin so this won't work in other shells
#
# The -v option means to print out verbose information about the command.
# That's not needed but with -v or -V (the -V gives more information) the exit
# code from command is 0 if the command is found or 127 if not.  Without one of
# -v or -V the exit status will be the exit status of the actual command, which
# is not what you want
#
# this will work even with the -e option turned on

if command -v cd 1>/dev/null; then
    echo "command cd was found"
else
    echo "command cd was not found"
fi

if command -v made-up-command 1>/dev/null; then
    echo "this made up command was found"
fi

if command -v ls 1>/dev/null; then
    echo "ls command was found"
fi

# furthermore we can functionalize this (notice that we enclose the command in
# quotes for commands that have spaces):

command_exists () {
    local command_name
    command_name="${1-}"

    if [[ "${command_name}" == "" ]]; then
        echo "ERROR: no command specified" >&2
        return 1
    fi

    if command -v "${command_name}" 1>/dev/null; then
        return 0
    else
        return 1
    fi
}

# Need the || true at the end or else the script will exit (which may be what
# you want)
command_exists || true
command_exists "cd" || echo "cd not found"
command_exists git || echo "git not found"
command_exists "git status" || echo "git status not found"


if command_exists "svn"; then
    echo "svn command was found"
else
    echo "svn command was not found"
fi

if command_exists "some-fake-name"; then
    echo "fake command exists"
fi

if ! command_exists "some-fake-name"; then
    echo "fake command does not exist, at this point I'd usually exit"
fi

echo "done"
