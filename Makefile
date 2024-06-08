all:
	dune build
test:
	dune runtest
clean:
	dune clean

setup:
	opam install --deps-only .
