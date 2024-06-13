(lang dune 3.7)
; use >3.7 otherwise 2.9 will generate error about bin broken symlink
(name hello-world)
(version 0.2.0)

(package
 (name hello-world)
 (synopsis "A simple example of an OCaml project")
 (description "A _really_ long description of a simple project")
 (source (github semgrep/hello-world-ocaml))
 (authors "Yoann Padioleau <pad@semgrep.com>" "Austin Theriault <austin@semgrep.com>")
 (maintainers "Yoann Padioleau <pad@semgrep.com>" "Austin Theriault <austin@semgrep.com>")
 (depends
  ; DO NOT declare dune or odoc as dependencies, dune will automatically add them
  (ocaml (>= 4.14.0))
  atdgen
  (yojson (>= 2.0.0))
  ppxlib
  ppx_deriving
  ppx_inline_test
  (ocamlformat :with-test)
  ; if we want to depend only for testing
  ;(alcotest :with-test)
))
(generate_opam_files)
