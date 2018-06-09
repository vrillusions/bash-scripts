
# only intended to be sourced, not run directly so no `#!/bin/bash`
# shellcheck shell=bash
#
# Prints the given value as a decimal. This is used because bash will see
# numbers with a leading zero as an octal value. This function reassigns the
# value prefixing it with '10#' which says to treat it as base-10 which has the
# result of removing leading zeros. This is all needed because it's possible to
# get a value for day with a leading zero.
#
# Usage:
#     print_dec <VALUE>
#
# Example:
#     DATE_DAY=$(date +"%d")
#     DATE_DAY=$(print_dec ${DATE_DAY})
#
#     # Or combined on one line
#     DATE_DAY=$(print_dec $(date +"%d"))
#
print_dec () {
    local value
    value=$(( 10#$1 ))
    printf "%d" $value
}
