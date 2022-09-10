# just is a handy way to save and run project-specific commands.
#
# https://github.com/casey/just

# list all tasks
default:
  just --list

# Format the code
fmt:
  treefmt
alias f := fmt

