
(* The type of tokens. *)

type token = 
  | WHILE
  | VAR
  | T_INT
  | T_BOOL
  | SUB
  | SEMI
  | RPAR
  | RETURN
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
  | IF
  | IDENT of (string)
  | GT
  | GE
  | EQUAL
  | EQ
  | EOF
  | END
  | ELSE
  | DIV
  | BOOL of (bool)
  | BEGIN
  | AND
  | ADD

(* This exception is raised by the monolithic API functions. *)

exception Error

(* The monolithic API. *)

val program: (Lexing.lexbuf -> token) -> Lexing.lexbuf -> (Kawa.program)
