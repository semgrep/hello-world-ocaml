module AT = ANSITerminal

(* There are many kind of "terminals".
 * Under Unix: xterm, rxvt, Gnome Terminal, ... and the raw Linux tty
 * but they are all ANSI sequence compliant.
 * Under macOS: default terminal, iTerm, ...
 * also compliant.
 * Under Windows:
 *  - Command prompt (by default)
 *  - basic Windows Powershell (by default)
 *  - Console host (ConHost.exe, also by default)
 *  - Windows terminal (not by default!)
 *    must be installed here https://apps.microsoft.com/detail/9n0dx20hk701?rtc=1&hl=es-es&gl=ES
 * Only the last one is ANSI sequence compliant.
 *)

let () =
  print_endline Msg.greeting;
  (* Using raw escape sequences (from chatGPT). This does not work under the basic
   * powershell but works under the Windows terminal!
   * See https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_ansi_terminals?view=powershell-7.4
   * 
   *)
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
                        

