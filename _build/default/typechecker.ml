open Kawa

exception Error of string
let error s = raise (Error s)
let type_error ty_actual ty_expected =
  error (Printf.sprintf "expected %s, got %s"
           (typ_to_string ty_expected) (typ_to_string ty_actual))

module Env = Map.Make(String)
type tenv = typ Env.t

let add_env l tenv =
  List.fold_left (fun env (x, t) -> Env.add x t env) tenv l

let typecheck_prog p =
  let tenv = add_env p.globals Env.empty in

  let rec check e typ tenv =
    let typ_e = type_expr e tenv in
    if typ_e <> typ then type_error typ_e typ

  and type_expr e tenv = match e with
    | Int _  -> TInt
    | Bool _ -> TBool
    | Unop(Opp, e) -> check e TInt tenv; TInt
    | Unop(Not, e) -> check e TBool tenv; TBool
    | Binop(And, e1, e2) | Binop(Or, e1, e2) -> check e1 TBool tenv; check e2 TBool tenv; TBool
    | Binop(Eq, e1, e2) | Binop(Neq, e1, e2) ->
      (match type_expr e1 tenv with
        | TInt ->  check e2 TInt tenv; TBool
        | TBool ->  check e2 TBool tenv; TBool
        | TClass(c) -> check e2 (TClass(c)) tenv; TBool
        | TVoid -> check e2 TVoid tenv; TBool)
    | Binop(Gt, e1, e2) | Binop(Ge, e1, e2) | Binop(Lt, e1, e2) | Binop(Le, e1, e2) ->
      check e1 TInt tenv; check e2 TInt tenv; TBool
    | Binop(_, e1, e2) -> check e1 TInt tenv; check e2 TInt tenv; TInt
    | Get(m) -> type_mem_access m tenv
    | This -> Env.find "this" tenv
    | New(s) -> check_class s [] tenv; TClass(s)
    | NewCstr(s, args) -> check_class s args tenv;
                          let cl = List.find (fun x -> x.class_name = s) p.classes in
                          TClass(cl.class_name)
    | MethCall(e, s, args) -> let t = type_expr e tenv in
                              (match t with
                              | TClass(c) -> check_mdef c s args tenv;
                                let cl = List.find (fun x -> x.class_name = c) p.classes in
                                let m = List.find (fun x -> x.method_name = s) cl.methods in
                              m.return
                              | _ -> error (Printf.sprintf "Method applied to a non-object expression"))

  and type_mem_access m tenv = match m with
    | Var(s) -> let t = Env.find_opt s tenv in
                (match t with
                | Some(v) -> v
                | None -> error (Printf.sprintf "Variable %s does not exist" s))
    | Field(e, s) -> (match type_expr e tenv with
                      | TClass(c) -> let cl = List.find (fun x -> x.class_name = c) p.classes in
                                     if not (List.mem s (List.map fst cl.attributes)) then error (Printf.sprintf "Attribute %s is not defined for class %s" s cl.class_name);
                                     snd (List.find (fun x -> fst x = s) cl.attributes)
                      | _ -> error (Printf.sprintf "Methos %s is not applied to a class" s))
  
  and check_class c args tenv =
    match args with
    | [] -> if not (List.exists (fun x -> x.class_name = c) p.classes) then error (Printf.sprintf "Class %s does not exist" c)
    | _ -> let cl = List.find_opt (fun x -> x.class_name = c) p.classes in
            (match cl with
            | None -> error (Printf.sprintf "Class %s does not exist" c)
            | Some cl ->
            let attr = List.map snd (List.find (fun x -> x.class_name = c) p.classes).attributes in
            let args = List.map (fun a -> type_expr a tenv) args in
            if attr <> args then error (Printf.sprintf "Wrong number of arguments in class %s" cl.class_name))
  
  and check_mdef c m args tenv =
    let cl = List.find (fun x -> x.class_name = c) p.classes in
    if not (List.mem m (List.map (fun a -> a.method_name) cl.methods)) then error (Printf.sprintf "Method %s not found for class %s" m cl.class_name);
    let m = List.find (fun x -> x.method_name = m) cl.methods in
    let attr = List.map snd m.params in
    let args = List.map (fun a -> type_expr a tenv) args in
    if attr <> args then error (Printf.sprintf "Wrong number of arguments in method %s from class %s" m.method_name cl.class_name)
  in

  let rec check_instr i ret tenv = match i with
    | Print e -> (match type_expr e tenv with
                  | TInt -> ()
                  | TBool -> ()
                  | TClass(s) -> ()
                  | TVoid -> ())
    | Set (m, e) -> let tm = type_mem_access m tenv in
                    check e tm tenv
    | If (e, s1, s2) -> check e TBool tenv;
                        check_seq s1 ret tenv;
                        check_seq s2 ret tenv
    | While (e, s) -> check e TBool tenv;
                      check_seq s ret tenv
    | Return e -> check e ret tenv
    | Expr e -> check e ret tenv
  and check_seq s ret tenv =
    List.iter (fun i -> check_instr i ret tenv) s
  in

  check_seq p.main TVoid tenv
