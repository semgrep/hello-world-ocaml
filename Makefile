
#alt: could dune build _build/install/default/bin/main.exe
all:
	dune build
test:
	dune runtest
clean:
	dune clean

setup:
	opam install --deps-only .
