open Stdlib
open Str

let run_command cmd =
  let in_chan = Unix.open_process_in cmd in
  let rec read_output acc =
    try
      let line = input_line in_chan in
      read_output (line :: acc)
    with End_of_file -> List.rev acc
  in
  read_output []

let ssh_command host cmd =
  let cmd = Printf.sprintf "ssh %s '%s'" host cmd in
  run_command cmd

let to_tuple xs =
  match xs with [ a; b ] -> (a, b) | _ -> failwith "Should be a tuple"

let read_file filename =
  let lines = ref [] in
  let ic = open_in filename in
  try
    while true do
      let line = input_line ic in
      lines := line :: !lines
    done;
    assert false (* Never reached *)
  with End_of_file ->
    close_in ic;
    String.concat "\n" (List.rev !lines)

let write_script filename content =
  let oc = open_out filename in
  Printf.fprintf oc "%s" content;
  close_out oc

let get_remote_home host =
  let cmd = Printf.sprintf "echo $HOME" in
  ssh_command host cmd |> List.hd

let send_string_to_file host source_file remote_path =
  let command = "scp " ^ source_file ^ " " ^ host ^ ":" ^ remote_path in
  print_endline command;
  Unix.system command |> ignore

let replace_in_string content replace_patterns =
  let patterns =
    List.map (fun s -> String.split_on_char '=' s) replace_patterns
    |> List.map to_tuple
  in
  List.fold_left
    (fun acc (a, b) -> global_replace (regexp_string ("$" ^ a)) b acc)
    content patterns