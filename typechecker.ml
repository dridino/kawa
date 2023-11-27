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
    | New(s) -> if not (List.exists (fun x -> x.class_name = s) p.classes) then error (Printf.sprintf "Class %s does not exist" s); TClass(s)
    | NewCstr(s, args) -> let cl = List.find_opt (fun x -> x.class_name = s) p.classes in
                          (match cl with
                          | None -> error (Printf.sprintf "Class %s does not exist" s)
                          | Some cl ->
                          let attr = List.map snd (List.find (fun x -> x.class_name = s) p.classes).attributes in
                          let args = List.map (fun a -> type_expr a tenv) args in
                          if attr <> args then error (Printf.sprintf "Wrong number of arguments in class %s" cl.class_name) else TClass(cl.class_name))
    | MethCall(e, s, args) -> let t = type_expr e tenv in
                              (match t with
                              | TClass(c) -> let cl = List.find (fun x -> x.class_name = c) p.classes in
                                             if not (List.mem s (List.map (fun a -> a.method_name) cl.methods)) then error (Printf.sprintf "Method %s not found for class %s" s cl.class_name);
                                             let m = List.find (fun x -> x.method_name = s) cl.methods in
                                             let attr = List.map snd m.params in
                                             let args = List.map (fun a -> type_expr a tenv) args in
                                             if attr <> args then error (Printf.sprintf "Wrong number of arguments in method %s from class %s" m.method_name cl.class_name) else m.return
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
    | _ -> failwith "case not implemented in type_mem_access"
  in

(* TODO : les instructions *)

  let rec check_instr i ret tenv = match i with
    | Print e -> check e TInt tenv
    | _ -> failwith "case not implemented in check_instr"
  and check_seq s ret tenv =
    List.iter (fun i -> check_instr i ret tenv) s
  in

  check_seq p.main TVoid tenv
