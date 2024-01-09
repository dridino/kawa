# 1 "kawalexer.mll"
 

  open Lexing
  open Kawaparser

  exception Error of string

  let keyword_or_ident =
  let h = Hashtbl.create 20 in
  List.iter (fun (s, k) -> Hashtbl.add h s k)
    [ "print",      PRINT;
      "assert",     ASSERT;
      "main",       MAIN;
      "false",      BOOL(false);
      "true",       BOOL(true);
      "int",        T_INT;
      "bool",       T_BOOL;
      "if",         IF;
      "else",       ELSE;
      "while",      WHILE;
      "return",     RETURN;
      "class",      CLASS;
      "new",        NEW;
      "void",       VOID;
      "method",     METHOD;
      "this",       THIS;
      "extends",    EXTENDS;
      "string",     T_STR;
    ] ;
  fun s ->
    try  Hashtbl.find h s
    with Not_found -> IDENT(s)
        

# 37 "kawalexer.ml"
let __ocaml_lex_tables = {
  Lexing.lex_base =
   "\000\000\222\255\223\255\224\255\225\255\226\255\227\255\002\000\
    \001\000\002\000\003\000\031\000\033\000\238\255\240\255\242\255\
    \243\255\244\255\245\255\246\255\247\255\001\000\079\000\163\000\
    \238\000\248\000\095\000\193\000\255\255\252\255\086\000\253\255\
    \248\255\104\000\237\255\236\255\234\255\232\255\231\255\230\255\
    \097\000\253\255\254\255\011\000\255\255";
  Lexing.lex_backtrk =
   "\255\255\255\255\255\255\255\255\255\255\255\255\255\255\032\000\
    \032\000\022\000\020\000\026\000\027\000\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\032\000\006\000\005\000\
    \004\000\014\000\016\000\001\000\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\001\000\255\255";
  Lexing.lex_default =
   "\002\000\000\000\000\000\000\000\000\000\000\000\000\000\255\255\
    \255\255\255\255\255\255\255\255\255\255\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\033\000\255\255\255\255\
    \255\255\255\255\255\255\255\255\000\000\000\000\030\000\000\000\
    \000\000\033\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \042\000\000\000\000\000\255\255\000\000";
  Lexing.lex_trans =
   "\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\027\000\028\000\000\000\000\000\027\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \027\000\011\000\021\000\032\000\000\000\013\000\008\000\038\000\
    \019\000\018\000\014\000\015\000\005\000\025\000\006\000\026\000\
    \024\000\024\000\024\000\024\000\024\000\024\000\024\000\024\000\
    \024\000\024\000\044\000\020\000\010\000\012\000\009\000\037\000\
    \036\000\022\000\022\000\022\000\022\000\022\000\022\000\022\000\
    \022\000\022\000\022\000\022\000\022\000\022\000\022\000\022\000\
    \022\000\022\000\022\000\022\000\022\000\022\000\022\000\022\000\
    \022\000\022\000\022\000\004\000\035\000\003\000\034\000\023\000\
    \031\000\023\000\023\000\023\000\023\000\023\000\023\000\023\000\
    \023\000\023\000\023\000\023\000\023\000\023\000\023\000\023\000\
    \023\000\023\000\023\000\023\000\023\000\023\000\023\000\023\000\
    \023\000\023\000\023\000\017\000\007\000\016\000\039\000\022\000\
    \022\000\022\000\022\000\022\000\022\000\022\000\022\000\022\000\
    \022\000\029\000\032\000\043\000\000\000\000\000\030\000\000\000\
    \022\000\022\000\022\000\022\000\022\000\022\000\022\000\022\000\
    \022\000\022\000\022\000\022\000\022\000\022\000\022\000\022\000\
    \022\000\022\000\022\000\022\000\022\000\022\000\022\000\022\000\
    \022\000\022\000\000\000\000\000\000\000\000\000\022\000\000\000\
    \022\000\022\000\022\000\022\000\022\000\022\000\022\000\022\000\
    \022\000\022\000\022\000\022\000\022\000\022\000\022\000\022\000\
    \022\000\022\000\022\000\022\000\022\000\022\000\022\000\022\000\
    \022\000\022\000\027\000\000\000\000\000\000\000\027\000\000\000\
    \000\000\000\000\000\000\023\000\023\000\023\000\023\000\023\000\
    \023\000\023\000\023\000\023\000\023\000\000\000\000\000\000\000\
    \000\000\027\000\000\000\000\000\023\000\023\000\023\000\023\000\
    \023\000\023\000\023\000\023\000\023\000\023\000\023\000\023\000\
    \023\000\023\000\023\000\023\000\023\000\023\000\023\000\023\000\
    \023\000\023\000\023\000\023\000\023\000\023\000\000\000\000\000\
    \001\000\255\255\023\000\000\000\023\000\023\000\023\000\023\000\
    \023\000\023\000\023\000\023\000\023\000\023\000\023\000\023\000\
    \023\000\023\000\023\000\023\000\023\000\023\000\023\000\023\000\
    \023\000\023\000\023\000\023\000\023\000\023\000\024\000\024\000\
    \024\000\024\000\024\000\024\000\024\000\024\000\024\000\024\000\
    \024\000\024\000\024\000\024\000\024\000\024\000\024\000\024\000\
    \024\000\024\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\255\255\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\041\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \255\255\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000";
  Lexing.lex_check =
   "\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\000\000\000\000\255\255\255\255\000\000\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \000\000\000\000\000\000\021\000\255\255\000\000\000\000\008\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\043\000\000\000\000\000\000\000\000\000\009\000\
    \010\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\011\000\000\000\012\000\000\000\
    \030\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\007\000\022\000\
    \022\000\022\000\022\000\022\000\022\000\022\000\022\000\022\000\
    \022\000\026\000\033\000\040\000\255\255\255\255\026\000\255\255\
    \022\000\022\000\022\000\022\000\022\000\022\000\022\000\022\000\
    \022\000\022\000\022\000\022\000\022\000\022\000\022\000\022\000\
    \022\000\022\000\022\000\022\000\022\000\022\000\022\000\022\000\
    \022\000\022\000\255\255\255\255\255\255\255\255\022\000\255\255\
    \022\000\022\000\022\000\022\000\022\000\022\000\022\000\022\000\
    \022\000\022\000\022\000\022\000\022\000\022\000\022\000\022\000\
    \022\000\022\000\022\000\022\000\022\000\022\000\022\000\022\000\
    \022\000\022\000\027\000\255\255\255\255\255\255\027\000\255\255\
    \255\255\255\255\255\255\023\000\023\000\023\000\023\000\023\000\
    \023\000\023\000\023\000\023\000\023\000\255\255\255\255\255\255\
    \255\255\027\000\255\255\255\255\023\000\023\000\023\000\023\000\
    \023\000\023\000\023\000\023\000\023\000\023\000\023\000\023\000\
    \023\000\023\000\023\000\023\000\023\000\023\000\023\000\023\000\
    \023\000\023\000\023\000\023\000\023\000\023\000\255\255\255\255\
    \000\000\021\000\023\000\255\255\023\000\023\000\023\000\023\000\
    \023\000\023\000\023\000\023\000\023\000\023\000\023\000\023\000\
    \023\000\023\000\023\000\023\000\023\000\023\000\023\000\023\000\
    \023\000\023\000\023\000\023\000\023\000\023\000\024\000\024\000\
    \024\000\024\000\024\000\024\000\024\000\024\000\024\000\024\000\
    \025\000\025\000\025\000\025\000\025\000\025\000\025\000\025\000\
    \025\000\025\000\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\030\000\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\040\000\255\255\255\255\255\255\255\255\255\255\255\255\
    \033\000\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255";
  Lexing.lex_base_code =
   "";
  Lexing.lex_backtrk_code =
   "";
  Lexing.lex_default_code =
   "";
  Lexing.lex_trans_code =
   "";
  Lexing.lex_check_code =
   "";
  Lexing.lex_code =
   "";
}

let rec token lexbuf =
   __ocaml_lex_token_rec lexbuf 0
and __ocaml_lex_token_rec lexbuf __ocaml_lex_state =
  match Lexing.engine __ocaml_lex_tables __ocaml_lex_state lexbuf with
      | 0 ->
# 44 "kawalexer.mll"
                      ( new_line lexbuf; token lexbuf )
# 211 "kawalexer.ml"

  | 1 ->
# 45 "kawalexer.mll"
                      ( token lexbuf )
# 216 "kawalexer.ml"

  | 2 ->
# 47 "kawalexer.mll"
                         ( new_line lexbuf; token lexbuf )
# 221 "kawalexer.ml"

  | 3 ->
# 48 "kawalexer.mll"
                         ( comment lexbuf; token lexbuf )
# 226 "kawalexer.ml"

  | 4 ->
let
# 50 "kawalexer.mll"
              n
# 232 "kawalexer.ml"
= Lexing.sub_lexeme lexbuf lexbuf.Lexing.lex_start_pos lexbuf.Lexing.lex_curr_pos in
# 50 "kawalexer.mll"
                 ( INT(int_of_string n) )
# 236 "kawalexer.ml"

  | 5 ->
let
# 51 "kawalexer.mll"
             id
# 242 "kawalexer.ml"
= Lexing.sub_lexeme lexbuf lexbuf.Lexing.lex_start_pos lexbuf.Lexing.lex_curr_pos in
# 51 "kawalexer.mll"
                 ( keyword_or_ident id )
# 246 "kawalexer.ml"

  | 6 ->
let
# 52 "kawalexer.mll"
                   id
# 252 "kawalexer.ml"
= Lexing.sub_lexeme lexbuf lexbuf.Lexing.lex_start_pos lexbuf.Lexing.lex_curr_pos in
# 52 "kawalexer.mll"
                      ( CIDENT id )
# 256 "kawalexer.ml"

  | 7 ->
let
# 54 "kawalexer.mll"
           s
# 262 "kawalexer.ml"
= Lexing.sub_lexeme lexbuf lexbuf.Lexing.lex_start_pos lexbuf.Lexing.lex_curr_pos in
# 54 "kawalexer.mll"
             ( STR(String.sub s 1 (String.length s - 2)) )
# 266 "kawalexer.ml"

  | 8 ->
# 56 "kawalexer.mll"
         ( SEMI )
# 271 "kawalexer.ml"

  | 9 ->
# 57 "kawalexer.mll"
         ( LPAR )
# 276 "kawalexer.ml"

  | 10 ->
# 58 "kawalexer.mll"
         ( RPAR )
# 281 "kawalexer.ml"

  | 11 ->
# 59 "kawalexer.mll"
         ( BEGIN )
# 286 "kawalexer.ml"

  | 12 ->
# 60 "kawalexer.mll"
         ( END )
# 291 "kawalexer.ml"

  | 13 ->
# 62 "kawalexer.mll"
        ( ADD )
# 296 "kawalexer.ml"

  | 14 ->
# 63 "kawalexer.mll"
        ( SUB )
# 301 "kawalexer.ml"

  | 15 ->
# 64 "kawalexer.mll"
        ( MUL )
# 306 "kawalexer.ml"

  | 16 ->
# 65 "kawalexer.mll"
        ( DIV )
# 311 "kawalexer.ml"

  | 17 ->
# 66 "kawalexer.mll"
        ( REM )
# 316 "kawalexer.ml"

  | 18 ->
# 68 "kawalexer.mll"
         ( EQ )
# 321 "kawalexer.ml"

  | 19 ->
# 69 "kawalexer.mll"
         ( NEQ )
# 326 "kawalexer.ml"

  | 20 ->
# 70 "kawalexer.mll"
         ( LT )
# 331 "kawalexer.ml"

  | 21 ->
# 71 "kawalexer.mll"
         ( LE )
# 336 "kawalexer.ml"

  | 22 ->
# 72 "kawalexer.mll"
         ( GT )
# 341 "kawalexer.ml"

  | 23 ->
# 73 "kawalexer.mll"
         ( GE )
# 346 "kawalexer.ml"

  | 24 ->
# 74 "kawalexer.mll"
         ( AND )
# 351 "kawalexer.ml"

  | 25 ->
# 75 "kawalexer.mll"
         ( OR )
# 356 "kawalexer.ml"

  | 26 ->
# 76 "kawalexer.mll"
        ( NOT )
# 361 "kawalexer.ml"

  | 27 ->
# 78 "kawalexer.mll"
        ( EQUAL )
# 366 "kawalexer.ml"

  | 28 ->
# 80 "kawalexer.mll"
        ( DOT )
# 371 "kawalexer.ml"

  | 29 ->
# 82 "kawalexer.mll"
        ( COMMA )
# 376 "kawalexer.ml"

  | 30 ->
# 84 "kawalexer.mll"
        ( LSQR )
# 381 "kawalexer.ml"

  | 31 ->
# 85 "kawalexer.mll"
        ( RSQR )
# 386 "kawalexer.ml"

  | 32 ->
# 87 "kawalexer.mll"
         ( raise (Error ("unknown character : " ^ lexeme lexbuf)) )
# 391 "kawalexer.ml"

  | 33 ->
# 88 "kawalexer.mll"
         ( EOF )
# 396 "kawalexer.ml"

  | __ocaml_lex_state -> lexbuf.Lexing.refill_buff lexbuf;
      __ocaml_lex_token_rec lexbuf __ocaml_lex_state

and comment lexbuf =
   __ocaml_lex_comment_rec lexbuf 40
and __ocaml_lex_comment_rec lexbuf __ocaml_lex_state =
  match Lexing.engine __ocaml_lex_tables __ocaml_lex_state lexbuf with
      | 0 ->
# 91 "kawalexer.mll"
         ( () )
# 408 "kawalexer.ml"

  | 1 ->
# 92 "kawalexer.mll"
         ( comment lexbuf )
# 413 "kawalexer.ml"

  | 2 ->
# 93 "kawalexer.mll"
         ( raise (Error "unterminated comment") )
# 418 "kawalexer.ml"

  | __ocaml_lex_state -> lexbuf.Lexing.refill_buff lexbuf;
      __ocaml_lex_comment_rec lexbuf __ocaml_lex_state

;;

