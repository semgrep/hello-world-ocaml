###############################################################################
# Build (and clean) targets
###############################################################################

# First (and default) target
default: all

#alt: could dune build _build/install/default/bin/hello instead
# which would be faster on big a big repo with many targets
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
###############################################################################
# Nix targets
###############################################################################

# The finger stuff here is weird but it's so we can get the user shell and run
# it in the nix shell. I.e. /usr/bin/zsh or /usr/bin/fish
# It's really weird because by default makefile overrides $SHELL so this is the
# only way to get it
shell:
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
format:
	dune fmt

utop:
	dune utop

doc:
	dune build @doc
