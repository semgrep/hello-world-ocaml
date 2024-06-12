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
	echo TODO

###############################################################################
# Test target
###############################################################################

#TODO: use Testo
test:
	dune runtest

###############################################################################
# Dependencies
###############################################################################

#TODO? rely on depext for system libs?
install-deps:
	opam install --deps-only .

#TODO: nix?

###############################################################################
# Developer targets
###############################################################################

setup:
	opam install --deps-only .
