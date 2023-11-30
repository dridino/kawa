
(* The type of tokens. *)

type token = 
  | WHILE
  | VOID
  | VAR
  | T_INT
  | T_BOOL
  | THIS
  | SUB
  | SEMI
  | RPAR
  | RETURN
  | REM
  | PRINT
  | OR
  | NOT
  | NEW
  | NEQ
  | MUL
  | METHOD
  | MAIN
  | LT
  | LPAR
  | LE
  | INT of (int)
  | IF
  | IDENT of (string)
  | GT
  | GE
  | EXTENDS
  | EQUAL
  | EQ
  | EOF
  | END
  | ELSE
  | DOT
  | DIV
  | COMMA
  | CLASS
  | BOOL of (bool)
  | BEGIN
  | ATTR
  | AND
  | ADD

(* This exception is raised by the monolithic API functions. *)

exception Error

(* The monolithic API. *)

val program: (Lexing.lexbuf -> token) -> Lexing.lexbuf -> (Kawa.program)
