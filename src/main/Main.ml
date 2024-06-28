module AT = ANSITerminal

let () =
  print_endline Msg.greeting;
  (* this actually does not work on Windows (and known to not work).
   * From the doc: https://chris00.github.io/ANSITerminal/doc/ANSITerminal/ANSITerminal/index.html
   *  "This only works on ANSI compliant terminals — for which escape sequences
   *    are used — and not under Windows — where system calls are required."
   *)
  let str =
    AT.sprintf [AT.green] "Hello" ^ AT.sprintf [AT.blue] " World" in
  print_endline str;

  (* this works *)
  AT.print_string [AT.green] "Hello ";
  AT.print_string [AT.blue] "Hello ";
  
  ()

