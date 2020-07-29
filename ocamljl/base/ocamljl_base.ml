external dummy: unit -> unit = "dummy_ocamljl_base"

let caml_exception_string e =
  let msg = Printexc.to_string e
  and stack = Printexc.get_backtrace () in
  msg ^ "\n" ^ stack

let register () =
  Printexc.record_backtrace true;
  Callback.register "caml_exception_string" caml_exception_string