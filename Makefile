###############################################################################
# Platform config
###############################################################################

ifeq ($(shell uname -o),Cygwin)
  EXE = .exe
endif

###############################################################################
# Build and clean targets
###############################################################################

# First (and default) target
default: all

all:
	dune build
clean:
	dune clean

###############################################################################
# Install targets
###############################################################################

install:
	dune install

###############################################################################
# Test target
###############################################################################

#TODO: use Testo
test:
	dune runtest

###############################################################################
# Dependencies
###############################################################################

# create a switch with only the dependencies in _opam
# See: https://ocaml.org/docs/opam-switch-introduction#local-switches
setup:
	opam switch create . --deps-only -t -d -y

# update the dependencies in the switch
update:
	opam install . --deps-only -t -d -y

# We remove the host-xxx packages because they would prevent to use the lock
# file on different platforms (e.g., Linux vs macOS and amd64 vs arm64).
#ugly: unfortunately there is no --no-depexts option to 'opam lock',
# so to run this command you must be in an impure nix-shell so that opam can
# check the presence of depext installer such as `pacman` in the PATH
hello-world.opam.locked: hello-world.opam
	opam lock ./hello-world.opam
	sed -i -e 's/.*host-arch.*//' $@
	sed -i -e 's/.*host-system.*//' $@

###############################################################################
# Nix targets
###############################################################################

# This uses shell.nix
shell:
	nix-shell --pure

# This uses flake.nix
# The finger stuff here is weird but it's so we can get the user shell and run
# it in the nix shell. I.e. /usr/bin/zsh or /usr/bin/fish
# It's really weird because by default makefile overrides $SHELL so this is the
# only way to get it
shell2:
	$(eval USER_SHELL := $(shell finger ${USER} | grep 'Shell:*' | cut -f3 -d ":"))
	nix develop -c $(USER_SHELL)

nix-build:
	nix build
nix-run:
	nix run
nix-fmt:
	nix fmt
nix-check: nix-check-flake
	nix flake check
# verbose check for CI
nix-check-verbose:
	nix flake check -L

###############################################################################
# Developer targets
###############################################################################

# on big repo this can be faster than dune build which will build everything
lite:
	dune build _build/install/default/bin/hello-world$(EXE)

format:
	dune fmt
utop:
	dune utop
doc:
	dune build @doc

pr:
	git push origin `git rev-parse --abbrev-ref HEAD`
	hub pull-request -b main
push:
	git push origin `git rev-parse --abbrev-ref HEAD`
merge:
	A=`git rev-parse --abbrev-ref HEAD` && git checkout main && git pull && git branch -D $$A

# to help debug PATH and other env vars issues in different OSes
show_env:
	env

exec_script:
	./scripts/simple_script.sh
