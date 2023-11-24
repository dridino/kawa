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
%token CLASS
%token ATTR
%token NEW
%token DOT

%left AND
%left OR
%left EQ NEQ
%left LT LE GT GE
%left ADD SUB
%left REM
%left MUL DIV
%nonassoc UMINUS
%nonassoc DOT

%start program
%type <Kawa.program> program

%%

program:
| globals=list(var_decl) classes=list(class_def) MAIN BEGIN main=list(instruction) END EOF
    { {classes=classes; globals=globals; main} }
;

class_def:
| CLASS i=IDENT BEGIN attr=list(attr_decl) END { {class_name=i; attributes=attr; methods=[]; parent=None} }

mem:
| i=IDENT { Var(i) }
| e=expression DOT i=IDENT { Field(e, i) }

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
| m=mem { Get(m) }
| u=unop e=expression %prec UMINUS { Unop(u, e) }
| e1=expression o=binop e2=expression { Binop(o, e1, e2) }
| LPAR e=expression RPAR { e }
| NEW i=IDENT { New(i) }
;

v_type:
| T_INT { TInt }
| T_BOOL { TBool }
| c=IDENT { TClass(c) }

var_decl:
| VAR t=v_type i=IDENT SEMI { (i, t) }

attr_decl:
| ATTR t=v_type i=IDENT SEMI { (i, t) }