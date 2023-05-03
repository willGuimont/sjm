open Stdlib
open Str

(* Constants *)

let home_dir = Sys.getenv "HOME"
let tmp_path = ".sjm/tmp"
let tmp_dir_local = Printf.sprintf "%s/.sjm/tmp" home_dir
let script_permission = 0o760

(* Helper function *)

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

let get_remote_tmp_dir host =
  let remote_home = get_remote_home host in
  Printf.sprintf "%s/%s" remote_home tmp_path

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

(* Actions *)

let create_tmp_dir host tmp_path_remote =
  let mk_cmd = Printf.sprintf "mkdir -p %s" in
  let cmd_local = mk_cmd tmp_dir_local in
  let cmd_remote = mk_cmd tmp_path_remote in
  run_command cmd_local |> ignore;
  ssh_command host cmd_remote |> ignore

let get_jobs host =
  let user = String.split_on_char '@' host |> List.hd in
  ssh_command host (Printf.sprintf "squeue -u %s" user)

let clear_job_cache () =
  run_command (Printf.sprintf "rm -r %s/*" tmp_dir_local) |> ignore

let clear_remote_job_cache host =
  let tmp_path_remote = get_remote_tmp_dir host in
  ssh_command host (Printf.sprintf "rm -r %s/*" tmp_path_remote) |> ignore

let submit_job host script_path replace_patterns =
  let script_content = read_file script_path in
  let script_content = replace_in_string script_content replace_patterns in

  let script_name = Printf.sprintf "tmp_%d.sh" (int_of_float (Unix.time ())) in
  let local_script_path = Printf.sprintf "%s/%s" tmp_dir_local script_name in
  let tmp_path_remote = get_remote_tmp_dir host in
  let remote_script_path = Printf.sprintf "%s/%s" tmp_path_remote script_name in

  let sbatch_command = Printf.sprintf "sbatch %s" remote_script_path in

  create_tmp_dir host tmp_path_remote;

  write_script local_script_path script_content;
  Unix.chmod local_script_path script_permission;

  send_string_to_file host local_script_path remote_script_path;
  ssh_command host sbatch_command
