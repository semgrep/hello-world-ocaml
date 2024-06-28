module AT = ANSITerminal

(* There are many kind of consoles a.k.a terminals.
 * Under Unix: xterm, rxvt, Gnome Terminal, ... and the raw Linux tty
 * They all understand ANSI sequence compliant (e.g., ANSI colors)
 * Under macOS: default terminal, iTerm, ...
 * also compliant.
 * Under Windows:
 *  - Command prompt (by default)
 *  - Windows Powershell (by default)
 *  - Console host conhost.exe (by default)
 *  - Windows terminal (not by default!), must be installed here
 *    https://apps.microsoft.com/detail/9n0dx20hk701?rtc=1&hl=es-es&gl=ES
 *  - Visual studio code integrated terminal
 *  - Cygwin terminal (not by default, and different world)
 * Only the last three are ANSI sequence compliant by default.
 * See https://stackoverflow.com/questions/51680709/colored-text-output-in-powershell-console-using-ansi-vt100-codes
 *
 * There are also many OCaml libraries to handle formatting in the terminal:
 *  - ANSITerminal
 *  - ocolor
 *  - lambda-term
 *  - ocaml-spectrum
 * You can also write the ANSI codes yourself in a string.
 *)

let test_terminal_libs () =
  (* Using raw escape sequences (from chatGPT). This does not work under the basic
   * powershell but works under the Windows terminal!
   * See https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_ansi_terminals?view=powershell-7.4
   * alt: use \027[
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

  (* this works everywhere, on all windows terminals *)
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
                        

