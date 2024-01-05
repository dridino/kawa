
(* The type of tokens. *)

type token = 
  | WHILE
  | VOID
  | VAR
  | T_STR
  | T_INT
  | T_BOOL
  | THIS
  | SUB
  | STR of (string)
  | SEMI
  | RSQR
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
  | LSQR
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
  | ASSERT
  | AND
  | ADD

(* This exception is raised by the monolithic API functions. *)

exception Error

(* The monolithic API. *)

val program: (Lexing.lexbuf -> token) -> Lexing.lexbuf -> (Kawa.program)
