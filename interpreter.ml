open Kawa

type value =
  | VInt  of int
  | VBool of bool
  | VObj  of obj
  | Null
and obj = {
  cls:    string;
  fields: (string, value) Hashtbl.t;
}

exception Error of string
exception Return of value

let exec_prog (p: program): unit =
  let env = Hashtbl.create 16 in
  List.iter (fun (x, _) -> Hashtbl.add env x Null) p.globals;
  
  let rec eval_call f this args =
    failwith "eval_call not implemented"

  and exec_seq s lenv =
    let rec evali e = match eval e with
      | VInt n -> n
      | _ -> assert false
    and evalb e = match eval e with
      | VBool b -> b
      | _ -> assert false
    and evalo e = match eval e with
      | VObj o -> o
      | _ -> assert false
        
    and eval (e: expr): value = match e with
      | Int n  -> VInt n
      | Bool b -> VBool b
      | Binop(Add, e1, e2) -> VInt ((evali e1) + (evali e2))
      | Binop(Sub, e1, e2) -> VInt ((evali e1) - (evali e2))
      | Binop(Mul, e1, e2) -> VInt ((evali e1) * (evali e2))
      | Binop(Div, e1, e2) -> VInt ((evali e1) / (evali e2))
      | Binop(Rem, e1, e2) -> VInt ((evali e1) mod (evali e2))

      | Binop(Eq, e1, e2) -> VBool ((eval e1) = (eval e2))
      | Binop(Neq, e1, e2) -> VBool ((eval e1) <> (eval e2))
      | Binop(Lt, e1, e2) -> VBool ((evali e1) < (evali e2))
      | Binop(Le, e1, e2) -> VBool ((evali e1) <= (evali e2))
      | Binop(Gt, e1, e2) -> VBool ((evali e1) > (evali e2))
      | Binop(Ge, e1, e2) -> VBool ((evali e1) >= (evali e2))
      | Binop(And, e1, e2) -> VBool ((evalb e1) && (evalb e2))
      | Binop(Or, e1, e2) -> VBool ((evalb e1) || (evalb e2))
      
      | Unop(Not, e) -> VBool (not (evalb e))
      | Unop(Opp, e) -> VInt (- (evali e))

      | Get m -> (match m with
          | Var s -> Hashtbl.find env s
          | Field (e, s) -> let o = evalo e in Hashtbl.find o.fields s)

      | New s -> let h = Hashtbl.create 4 in
                  let () = List.iter (fun (name, t) -> Hashtbl.add h name Null) (List.find (fun x -> x.class_name = s) p.classes).attributes in
                  VObj({cls=s; fields=h})

      | _ -> failwith "case not implemented in eval"
    in
  
    let rec exec (i: instr): unit = match i with
      | Print e -> let res = eval e in (match res with
          | VInt n -> Printf.printf "%d\n" n
          | VBool b -> Printf.printf "%b\n" b
          | Null -> Printf.printf "null\n"
          | _ -> failwith "case not implemented in exec (print)")
      | Set(m, e) -> (match m with
        | Var s -> let res = eval e in Hashtbl.add env s res
        | Field (ee, s) -> let o = evalo ee in Hashtbl.add o.fields s (eval e))
      | If(e, l1, l2) -> (match eval e with
        | VBool b -> if b then exec_seq l1 else exec_seq l2
        | VInt i -> if i <> 0 then exec_seq l1 else exec_seq l2
        | _ -> failwith "The condition of an `if` should be of type `int` or `bool`.")
      | While(e, l) -> (match eval e with
        | VBool b -> if b then let () = exec_seq l in exec (While(e, l)) else ()
        | VInt i -> if i <> 0 then let () = exec_seq l in exec (While(e, l)) else ()
        | _ -> failwith "The condition of a `while` should be of type `int` or `bool`.")
      | _ -> failwith "case not implemented in exec"
    and exec_seq s = 
      List.iter exec s
    in

    exec_seq s
  in
  
  exec_seq p.main (Hashtbl.create 1)
