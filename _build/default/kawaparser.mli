
(* The type of tokens. *)

type token = 
  | VOID
  | VAR
  | THIS
  | SUB
  | SEMI
  | RPAR
  | REM
  | PRINT
  | POINT
  | OR
  | OPP
  | NOT
  | NEW
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
  | EQUAL
  | EQ
  | EOF
  | END
  | DIV
  | CLASS of (string)
  | BOOL of (bool)
  | BEGIN
  | ATTRIBUTE
  | AND
  | ADD

(* This exception is raised by the monolithic API functions. *)

exception Error

(* The monolithic API. *)

val program: (Lexing.lexbuf -> token) -> Lexing.lexbuf -> (Kawa.program)
