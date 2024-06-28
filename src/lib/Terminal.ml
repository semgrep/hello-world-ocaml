(* There are many kinds of Consoles a.k.a Terminals.
 *
 * Under Linux: xterm, rxvt, Gnome Terminal, ... and the raw Linux ttys.
 * They all understand ANSI escape sequences (e.g., ANSI colors).
 * They are ANSI compliant.
 *
 * Under macOS: the default terminal, iTerm, ...
 * also ANSI compliant.
 *
 * Under Windows:
 *  - Command Prompt (available by default)
 *  - Windows Powershell (by default)
 *  - Console Host conhost.exe (by default)
 *  - Windows Terminal, a.k.a Terminal (not by default!), must be installed here
 *    https://apps.microsoft.com/detail/9n0dx20hk701?rtc=1&hl=es-es&gl=ES
 *  - Visual studio code integrated terminal (part of VScode)
 *  - Cygwin terminal (not by default, and different world)
 * Only the last three are ANSI compliant by default.
 * See https://stackoverflow.com/questions/51680709/colored-text-output-in-powershell-console-using-ansi-vt100-codes
 *
 * There are also many OCaml libraries to handle formatting in the terminal:
 *  - ANSITerminal:
 *    * pro: can display colors on Windows in the basic terminals such as
 *      the Command Prompt and Windows Powershell! In that case it does not
 *      rely on ANSI escape sequence but special system calls to Windows.
 *      It's the only library with lambda-term that can do that.
 *      Also it's pretty simple to use with a pretty small API.
 *      It can also handle cursors and do effect like spinners (but this might
 *      not work under windows actually).
 *    * cons: you can't use ANSITerminal.sprintf; only the printf variant
 *      handle windows (because it does not rely on escape code in the
 *      string but special calls). The sprintf will not even work in the
 *      Windows Terminal.
 *  - Fmt
 *    * pro: powerful combinators, support style and colors
 *    * cons: can't use colors with Fmt.str, and complicated API (formatters)
 *      with lots of use of "%a"
 *  - ocolor (ocolor_format and ocolor_printf)
 *    * pro: can use color tags as in @{<green>hello}
 *    * cons: does not seem to work consistently, and has weird behavior
 *      when combined with spectrum
 *  - ocaml-spectrum
 *    * pro: advanced coloring
 *    * cons: seems to have weird behavior when combined with ocolor_format
 *  - lambda-term
 *    * pro: used by utop, powerful library not just for colors
 *      but for ncurses like interactions, and it can handle basic terminals
 *      in Windows (as shown by utop)
 *    * cons: require use of lwt even for basic terminal output
 * You can also write the ANSI escape codes yourself in a string (this is
 * what Testo is doing in OSS/libs/testo/util/Style.ml).
 *)

let test_terminal_libs () =
  (* Using raw escape sequences (from chatGPT). This does not work under the basic
   * Windows Powershell but it works under the Windows Terminal!
   * See https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_ansi_terminals?view=powershell-7.4
   * alt: use \027[
   *)
  let red_text = "\x1b[31mHello, World!\x1b[0m (using raw escape code)" in
  Printf.printf "%s\n" red_text;

  (* force the use of Ansi_tty below, otherwise setup_std_outputs rely on defaults
   * which rely on $TERM which is not set in the Windows Terminal.
   *)
  Fmt_tty.setup_std_outputs ~style_renderer:`Ansi_tty ();
  let red_bold_formatter = Fmt.(styled `Bold (styled `Red string)) in
  Fmt.pr "%a (using Fmt styled)\n" red_bold_formatter "Hello, World!";
  Format.print_flush ();
  (* using sprintf style (does not print color actually) *)
  let str = Fmt.str "%a (using Fmt str)" red_bold_formatter "Hello, World!" in
  Fmt.pr "%s\n" str;
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
                        

