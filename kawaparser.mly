%{

  open Lexing
  open Kawa

%}

%token <int> INT
%token <bool> BOOL
%token VOID
%token <string> IDENT
%token MAIN
%token LPAR RPAR BEGIN END SEMI
%token PRINT
%token EOF
%token NOT
%token ADD SUB MUL DIV REM
%token EQ NEQ LT LE GT GE AND OR
%token VAR EQUAL
%token T_INT T_BOOL T_STR
%token IF ELSE
%token WHILE
%token RETURN
%token CLASS
%token ATTR
%token NEW
%token DOT
%token METHOD
%token THIS
%token COMMA
%token EXTENDS
%token LSQR RSQR
%token ASSERT
%token <string> STR
%token <string> CIDENT

%left AND
%left OR
%left EQ NEQ
%left LT LE GT GE
%left ADD SUB
%left REM
%left MUL DIV
%nonassoc UMINUS
%left LSQR
%left DOT

%start program
%type <Kawa.program> program

%%

program:
| globals=list(var_decl) classes=list(class_def) MAIN BEGIN main=list(instruction) END EOF
    { {classes=classes; globals=List.concat globals; main=main} }
;

param_decl:
| t=v_type i=IDENT { (i, t) }
;

extends_bloc:
| EXTENDS c=CIDENT { c }
;

m_type:
| t=v_type  { t }
| VOID      { TVoid }
;

method_def:
| METHOD t=m_type i=IDENT LPAR params=separated_list(COMMA, param_decl) RPAR BEGIN locals=list(var_decl) instr=list(instruction) END { {method_name=i; code=instr; params=params; locals=List.concat locals; return=t} }
;

class_def:
| CLASS i=CIDENT ext=option(extends_bloc) BEGIN attr=list(attr_decl) meth=list(method_def) END { {class_name=i; attributes=List.concat attr; methods=meth; parent=ext} }
;

mem:
| i=IDENT { Var(i) }
| e=expression DOT i=IDENT { Field(e, i) }
| e=expression LSQR i=INT RSQR { TabIdx(e, i) }
;

instruction:
| PRINT LPAR e=expression RPAR SEMI { Print(e) }
| m=mem EQUAL e=expression SEMI { Set(m, e) }
| IF LPAR e=expression RPAR BEGIN l1=list(instruction) END ELSE BEGIN l2=list(instruction) END { If(e, l1, l2) }
| WHILE LPAR e=expression RPAR BEGIN l=list(instruction) END { While(e, l) }
| RETURN e=expression SEMI { Return(e) }
| e=expression SEMI { Expr(e) }
| ASSERT LPAR e=expression RPAR SEMI { Assert(e) }
;

unop:
| SUB { Opp }
| NOT { Not }
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
| THIS { This }
| m=mem { Get(m) }
| u=unop e=expression %prec UMINUS { Unop(u, e) }
| e1=expression o=binop e2=expression { Binop(o, e1, e2) }
| LPAR e=expression RPAR { e }
| NEW i=CIDENT { New(i) }
| NEW i=CIDENT LPAR args=separated_list(COMMA, expression) RPAR { NewCstr(i, args) }
| e=expression DOT i=IDENT LPAR args=separated_list(COMMA, expression) RPAR { MethCall(e, i, args) }
| BEGIN l=separated_list(COMMA, expression) END { Tab(Array.of_list l, List.length l) }
| s=STR { Str(s) }
;

v_type:
| T_INT { TInt }
| T_BOOL { TBool }
| c=CIDENT { TClass(c) }
| T_STR   { TStr }
;

var_ident:
| i=IDENT { (i, None) }
| i=IDENT LSQR n=INT RSQR { (i, Some n) }
;

var_decl:
| t=v_type i=separated_list(COMMA, var_ident) SEMI { List.fold_left
    (fun init (id, len) -> match len with None -> (id, t, None)::init | Some n -> (id, TTab (t, n), None)::init) [] i }
| t=v_type i=var_ident EQUAL e=expression SEMI { [let i, len = i in match len with None -> (i, t, Some e) | Some len -> (i, TTab (t, len), Some e)] }
;

attr_decl:
| t=v_type i=separated_nonempty_list(COMMA, var_ident) SEMI { List.fold_left
    (fun init (id, len) -> match len with None -> (id, t)::init | Some n -> (id, TTab (t, n))::init) [] i }
;
