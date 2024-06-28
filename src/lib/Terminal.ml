(* There are many kinds of consoles a.k.a terminals.
 * Under Unix: xterm, rxvt, Gnome Terminal, ... and the raw Linux ttys
 * They all understand ANSI escape sequences (e.g., ANSI colors).
 * They are ANSI compliant.
 * Under macOS: default terminal, iTerm, ...
 * also ANSI compliant.
 * Under Windows:
 *  - Command prompt (available by default)
 *  - Windows Powershell (by default)
 *  - Console host conhost.exe (by default)
 *  - Windows terminal (not by default!), must be installed here
 *    https://apps.microsoft.com/detail/9n0dx20hk701?rtc=1&hl=es-es&gl=ES
 *  - Visual studio code integrated terminal (part of VScode)
 *  - Cygwin terminal (not by default, and different world)
 * Only the last three are ANSI compliant by default.
 * See https://stackoverflow.com/questions/51680709/colored-text-output-in-powershell-console-using-ansi-vt100-codes
 *
 * There are also many OCaml libraries to handle formatting in the terminal:
 *  - ANSITerminal
 *  - Fmt
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

  Fmt_tty.setup_std_outputs ~style_renderer:`Ansi_tty ();
  let red_bold_formatter = Fmt.(styled `Bold (styled `Red string)) in
  Fmt.pr "%a (using Fmt styled)\n" red_bold_formatter "Hello, World!";
  Format.print_flush ();

  (* This actually does not work on Windows (and known to not work).
   * Does not work neither in cygwin nor powershell.
   * From the doc: https://chris00.github.io/ANSITerminal/doc/ANSITerminal/ANSITerminal/index.html
   *  "This only works on ANSI compliant terminals — for which escape sequences
   *    are used — and not under Windows — where system calls are required."
   * In fact if you look at the source of ANSITerminal_win.ml, you'll see
   *    let sprintf _style = Printf.sprintf
   * so the styles are ignored.
   *)
  let str =
    ANSITerminal.sprintf [ANSITerminal.green] "Hello" ^ ANSITerminal.sprintf [ANSITerminal.blue] " World (ANSITerminal.sprintf)" in
  print_endline str;

  (* this works everywhere, on all windows terminals *)
  ANSITerminal.print_string [ANSITerminal.green] "Hello ";
  ANSITerminal.print_string [ANSITerminal.blue] "Hello (ANSITerminal.print_string)\n";

  Spectrum.Simple.printf "@{<green>%s@} (Spectrum)\n" "Hello world 👋";;

 (* WEIRD, even though it's here it's displayed at the beginning if you
    also use Spectrum at the same time. So weird.
  *)
  Ocolor_printf.printf "Hello world (Ocolor_printf)\n";
(* WEIRD this does not even work in Unix, not sure why *)
  Ocolor_format.printf "Hello World (Ocolor_format)\n";
  Format.print_flush ();
  (* alt: use lambda-term library, which is used in utop, but require
   * the use of lwt in its API, even for simple things.
   *)
  ()
                        

