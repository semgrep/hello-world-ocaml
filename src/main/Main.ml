module AT = ANSITerminal

let () =
  print_endline Msg.greeting;
  (* Using raw escape code, from chatGPT *)
  let red_text = "\x1b[31mHello, World!\x1b[0m (using raw escape code)" in
  Printf.printf "%s\n" red_text;

  (* This actually does not work on Windows (and known to not work).
   * Does not work neither in cygwin nor powershell.
   * From the doc: https://chris00.github.io/ANSITerminal/doc/ANSITerminal/ANSITerminal/index.html
   *  "This only works on ANSI compliant terminals — for which escape sequences
   *    are used — and not under Windows — where system calls are required."
   *)
  let str =
    AT.sprintf [AT.green] "Hello" ^ AT.sprintf [AT.blue] " World (ANSITerminal.sprintf)" in
  print_endline str;

  (* this works everywhere *)
  AT.print_string [AT.green] "Hello ";
  AT.print_string [AT.blue] "Hello (ANSITerminal.print_string)\n";
  
  (* WEIRD this does not even work in Unix, not sure why *)
  Ocolor_format.printf {|
   Hello World (Ocolor_format)
  |};
  Ocolor_printf.printf "No color (Ocolor_printf)\n";

  (* alt: use lambda-term library, which is used in utop, but require
   * the use of lwt in its API, even for simple things.
   *)
  ()
                        

