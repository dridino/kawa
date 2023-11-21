
(* The type of tokens. *)

type token = 
  | SUB
  | SEMI
  | RPAR
  | REM
  | PRINT
  | OR
  | NOT
  | NEQ
  | MUL
  | MAIN
  | LT
  | LPAR
  | LE
  | INT of (int)
  | IDENT of (string)
  | GT
  | GE
  | EQ
  | EOF
  | END
  | DIV
  | BOOL of (bool)
  | BEGIN
  | AND
  | ADD

(* This exception is raised by the monolithic API functions. *)

exception Error

(* The monolithic API. *)

val program: (Lexing.lexbuf -> token) -> Lexing.lexbuf -> (Kawa.program)
