{ config, lib, pkgs, ... }:
{
  home.file.".XCompose" = {
    text = ''
      # ~/.XCompose
      # This file defines custom Compose sequences for Unicode characters

      # Import default rules from the system Compose file:
      include "%L"
      # include "/usr/share/X11/locale/en_US.UTF-8/Compose"

      # To put some stuff onto compose key strokes:
      # <Multi_key> <minus> <greater> : "→" U2192 # Compose - >
      # <Multi_key> <colon> <parenright> : "☺" U263A   # Compose : )
      # <Multi_key> <h> <n> <k> : "hugs and kisses" # Compose h n k

      <Multi_key> <o> <h> <m> : "Ω" U2126 # Compose o h m
      # Greek
      <Multi_key> <A> <l> <p> <h> <a> : "Α" U0391
      <Multi_key> <a> <l> <p> <h> <a> : "α" U03B1
      <Multi_key> <B> <e> <t> <a> : "Β" U0392
      <Multi_key> <b> <e> <t> <a>  : "β" U03B2
      <Multi_key> <G> <a> <m> <m> <a>  : "Γ" U0393
      <Multi_key> <g> <a> <m> <m> <a>  : "γ" U03B3
      <Multi_key> <D> <e> <l> <t> <a>  : "Δ" U0394
      <Multi_key> <d> <e> <l> <t> <a>  : "δ" U03B4
      <Multi_key> <E> <p> <s> <i> <l> <o> <n> : "Ε" U0395
      <Multi_key> <e> <p> <s> <i> <l> <o> <n> : "ε" U03B5
      <Multi_key> <Z> <e> <t> <a>  : "Ζ" U0396
      <Multi_key> <z> <e> <t> <a>  : "ζ" U03B6
      <Multi_key> <E> <t> <a> : "Η" U0397
      <Multi_key> <e> <t> <a> : "η" U03B7
      <Multi_key> <T> <h> <e> <t> <a> : "Θ" U0398
      <Multi_key> <t> <h> <e> <t> <a> : "θ" U03B8
      <Multi_key> <I> <o> <t> <a>  : "Ι" U0399
      <Multi_key> <i> <o> <t> <a>  : "ι" U03B9
      <Multi_key> <K> <a> <p> <p> <a>  : "Κ" U039A
      <Multi_key> <k> <a> <p> <p> <a>  : "κ" U03BA
      <Multi_key> <L> <a> <m> <b> <d> <a> : "Λ" U039B
      <Multi_key> <l> <a> <m> <b> <d> <a> : "λ" U03BB
      <Multi_key> <M> <u> : "Μ" U039C
      <Multi_key> <m> <u> : "μ" U03BC
      <Multi_key> <N> <u> : "Ν" U039D
      <Multi_key> <n> <u> : "ν" U03BD
      <Multi_key> <X> <i> : "Ξ" U039E
      <Multi_key> <x> <i> : "ξ" U03BE
      <Multi_key> <O> <m> <i> <c> <r> <o> <n> : "Ο" U039F
      <Multi_key> <o> <m> <i> <c> <r> <o> <n> : "ο" U03BF
      <Multi_key> <P> <i> : "Π" U03A0
      <Multi_key> <p> <i> : "π" U03C0
      <Multi_key> <R> <h> <o> : "Ρ" U03A1
      <Multi_key> <r> <h> <o> : "ρ" U03C1
      # U03A2 is undefined, there's no capital final sigma in Greek.
      <Multi_key> <s> <i> <g> <m> <a> <f> : "ς" U03C2
      <Multi_key> <S> <i> <g> <m> <a> : "Σ" U03A3
      <Multi_key> <s> <i> <g> <m> <a> : "σ" U03C3
      <Multi_key> <T> <a> <u> : "Τ" U03A4
      <Multi_key> <t> <a> <u> : "τ" U03C4
      <Multi_key> <U> <p> <s> <i> <l> <o> <n> : "Υ" U03A5
      <Multi_key> <u> <p> <s> <i> <l> <o> <n> : "υ" U03C5
      <Multi_key> <P> <h> <i> : "Φ" U03A6
      <Multi_key> <p> <h> <i> : "φ" U03C6
      <Multi_key> <C> <h> <i> : "Χ" U03A7
      <Multi_key> <c> <h> <i> : "χ" U03C7
      <Multi_key> <P> <s> <i> : "Ψ" U03A8
      <Multi_key> <p> <s> <i> : "ψ" U03C8
      <Multi_key> <O> <m> <e> <g> <a> : "Ω" U03A9
      <Multi_key> <o> <m> <e> <g> <a> : "ω" U03C9
      # Misc unicode
      <Multi_key> <z> <space> : "​" U200B # Zero-width space
    '';
  };
}
