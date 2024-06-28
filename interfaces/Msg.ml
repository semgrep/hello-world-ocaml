module A = ANSITerminal

let greeting =
  A.sprintf [A.green] "Hello" ^ A.sprintf [A.blue] " World"

let%test "size" =
  String.length greeting = 11
