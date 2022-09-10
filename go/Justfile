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

# Build the code
build:
  go build -o ${PRJ_ROOT}/out/main main.go
alias b := build

# Cleans any build outputs
clean:
  rm -rf ${PRJ_ROOT}/out
alias c := clean