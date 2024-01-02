open Kawa

type value =
  | VInt  of int
  | VBool of bool
  | VObj  of obj
  | VTab  of value array * int
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
  Hashtbl.add env "$return_val" Null;

  let rec add_field c h =
    List.iter (fun (n, _) -> Hashtbl.add h n Null) c.attributes;
    match c.parent with
    | None -> ()
    | Some s -> let c' = List.find (fun x -> x.class_name = s) p.classes in
                add_field c' h
  in

  let rec all_methods c =
    let cl = (List.find (fun x -> x.class_name = c) p.classes) in
    match cl.parent with
    | None -> cl.methods
    | Some s -> cl.methods @ (all_methods (List.find (fun x -> x.class_name = s) p.classes).class_name)
  in
  
  let rec eval_call f this args constructor =
    let env' = Hashtbl.create 16 in
    Hashtbl.add env' "$return_val" Null;
    List.iter (fun (x,_) -> Hashtbl.add env' x (Hashtbl.find env x)) p.globals;
    List.iter2 (fun x y -> Hashtbl.add env' (fst y) x) args f.params;
    List.iter (fun (x, _) -> Hashtbl.add env' x Null) f.locals;
    Hashtbl.add env' "this" (VObj(this));
    exec_seq f.code env';
    if constructor then (Hashtbl.find env' "this") else (Hashtbl.find env' "$return_val")

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
          | Var s -> Hashtbl.find lenv s
          | Field (e, s) -> let o = evalo e in Hashtbl.find o.fields s
          | TabIdx(e, idx) -> let tab = eval e in
            match tab with
            | VTab(arr, len) -> Array.get arr idx
            | _ -> failwith "expected a tab")

      | New s -> let h = Hashtbl.create 4 in
                  add_field (List.find (fun x -> x.class_name = s) p.classes) h;
                  VObj({cls=s; fields=h})

      | NewCstr(s, args) -> let o = eval (New s) in
                            let m = List.find (fun x -> x.method_name = "constructor") (List.find (fun x -> x.class_name = s) p.classes).methods in
                            (match o with | VObj(o) -> eval_call m o (List.map eval args) true | _ -> failwith "error")
      
      | MethCall(e, s, args) -> let o = evalo e in
                                let methods = all_methods o.cls in
                                let m = List.find (fun x -> x.method_name = s) methods in
                                eval_call m o (List.map eval args) false

      | This -> Hashtbl.find lenv "this"

      | Tab(arr, len) -> VTab(Array.map eval arr, len)
    in

    let rec exec_print v =
      (match v with
          | VInt n -> Printf.printf "%d" n
          | VBool b -> Printf.printf "%b" b
          | Null -> Printf.printf "null"
          | VObj s -> Printf.printf "Object of class : %s" s.cls
          | VTab(arr, len) -> Printf.printf "[ "; Array.iter (fun x -> exec_print x; Printf.printf ", ") arr; Printf.printf " ]")
    in
    let rec exec (i: instr): unit = match i with
      | Print e -> let res = eval e in 
        exec_print res
      | Set(m, e) -> (match m with
        | Var s -> let res = eval e in Hashtbl.add lenv s res
        | Field (ee, s) -> let o = evalo ee in Hashtbl.add o.fields s (eval e)
        | TabIdx(arr, idx) -> let arr = eval arr in match arr with VTab(arr, len) -> Array.set arr idx (eval e) | _ -> failwith "expected array")
      | If(e, l1, l2) -> (match eval e with
        | VBool b -> if b then exec_seq l1 else exec_seq l2
        | VInt i -> if i <> 0 then exec_seq l1 else exec_seq l2
        | _ -> failwith "The condition of an `if` should be of type `int` or `bool`.")
      | While(e, l) -> (match eval e with
        | VBool b -> if b then let () = exec_seq l in exec (While(e, l)) else ()
        | VInt i -> if i <> 0 then let () = exec_seq l in exec (While(e, l)) else ()
        | _ -> failwith "The condition of a `while` should be of type `int` or `bool`.")
      | Return e -> raise (Return(eval e))
      | Expr e -> let _ = eval e in ()
    and exec_seq s =
      try
        List.iter exec s
      with
      | Return(v) -> Hashtbl.add lenv "$return_val" v
    in

    exec_seq s
  in
  
  exec_seq p.main env
