%{

  open Lexing
  open Kawa

%}

%token <int> INT
%token <string> IDENT
%token <bool> BOOL
%token <string> CLASS
%token MAIN
%token LPAR RPAR BEGIN END SEMI POINT
%token PRINT
%token EOF
%token VOID
%token VAR
%token ATTRIBUTE
%token OPP NOT
%token ADD SUB MUL DIV REM LT LE GT GE EQ NEQ AND OR
%token THIS
%token NEW
%token EQUAL

%start program
%type <Kawa.program> program

%%

program:
| MAIN BEGIN main=list(instruction) END EOF
    { {classes=[]; globals=[]; main} }
;

var_decl:
| VAR t=mem_access EQUAL i=IDENT SEMI { Set(i, t) }
;

instruction:
| PRINT LPAR e=expression RPAR SEMI { Print(e) }
| s=mem_access EQUAL e=expression { Set(s, e) }
;

unop:
| OPP { Opp }
| NOT { Not }
;

binop:
| ADD { Add }
| SUB { Sub }
| MUL { Mul }
| DIV { Div }
| REM { Rem }
| LT { Lt }
| LE { Le }
| GT { Gt }
| GE { Ge }
| EQ { Eq }
| NEQ { Neq }
| AND { And }
| OR { Or }
;

mem_access:
| s=IDENT { Var(s) }
| e=expression POINT s=IDENT { Field(e, s) }
;

expression:
| n=INT { Int(n) }
| b=BOOL { Bool(b) }
| o=unop e=expression { Unop(o, e) }
| e1=expression o=binop e2=expression { Binop(o, e1, e2) }
| m=mem_access { Get(m) }
| THIS { This }
| NEW s=IDENT { New(s) }
| LPAR e=expression RPAR { e }
;
