#!/bin/bash
## @file
## @brief A really complicated file
##
## A longer paragraph about this file.
##
## @par Environment variables
## The follow are a list of environment variables this script knows of
## @li @c VERBOSE displays more output. default is false

## @brief Display hello world to screen
## @param noop not really a parameter
## @return true
hello_world () {
    echo "Hello world"
}

hello_world
