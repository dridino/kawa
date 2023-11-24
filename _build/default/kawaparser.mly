%{

  open Lexing
  open Kawa

%}

%token <int> INT
%token <bool> BOOL
%token <string> IDENT
%token MAIN
%token LPAR RPAR BEGIN END SEMI
%token PRINT
%token EOF
%token NOT
%token ADD SUB MUL DIV REM
%token EQ NEQ LT LE GT GE AND OR
%token VAR EQUAL
%token T_INT T_BOOL
%token IF ELSE
%token WHILE
%token RETURN

%left AND
%left OR
%left EQ NEQ
%left LT LE GT GE
%left ADD SUB
%left REM
%left MUL DIV
%nonassoc UMINUS

%start program
%type <Kawa.program> program

%%

program:
| globals=list(var_decl) MAIN BEGIN main=list(instruction) END EOF
    { {classes=[]; globals=globals; main} }
;

mem:
| i=IDENT { Var(i) }

instruction:
| PRINT LPAR e=expression RPAR SEMI { Print(e) }
| m=mem EQUAL e=expression SEMI { Set(m, e) }
| IF LPAR e=expression RPAR BEGIN l1=list(instruction) END ELSE BEGIN l2=list(instruction) END { If(e, l1, l2) }
| WHILE LPAR e=expression RPAR BEGIN l=list(instruction) END { While(e, l) }
| RETURN e=expression SEMI { Return(e) } (* A traiter apres *)
| e=expression SEMI { Expr(e) }
;

unop:
| SUB { Opp }
| NOT { Not}
;

%inline binop:
| ADD { Add }
| SUB { Sub }
| MUL { Mul }
| DIV { Div }
| REM { Rem }
| EQ  { Eq }
| NEQ { Neq }
| LT  { Lt }
| LE  { Le }
| GT  { Gt }
| GE  { Ge }
| AND { And }
| OR  { Or }
;

expression:
| n=INT { Int(n) }
| b=BOOL { Bool(b) }
| e1=expression o=binop e2=expression { Binop(o, e1, e2) }
| u=unop e=expression %prec UMINUS { Unop(u, e) }
| LPAR e=expression RPAR { e }
| m=mem { Get(m) }
;

v_type:
| T_INT { TInt }
| T_BOOL { TBool }

var_decl:
| VAR t=v_type i=IDENT SEMI { (i, t) }