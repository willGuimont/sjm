open Stdlib
open Str

let tmp_job_dir = "~/.sjm/tmp"

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
  let cmd = Printf.sprintf "ssh %s \"%s\"" host cmd in
  run_command cmd

let get_jobs host =
  let user = String.split_on_char '@' host |> List.hd in
  ssh_command host (Printf.sprintf "squeue -u %s" user)

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

let clear_job_cache host =
  ssh_command host (Printf.sprintf "rm -rf %s/*" tmp_job_dir)

let create_job_tmp_dir host =
  ssh_command host (Printf.sprintf "mkdir -p %s" tmp_job_dir)

let send_string_to_file host content =
  run_command
    (Printf.sprintf "echo \"%s\" | ssh %s 'cat > %s/tmp.sh'" content host
       tmp_job_dir)

let submit_job host script replace_patterns =
  let patterns =
    List.map (fun s -> String.split_on_char '=' s) replace_patterns
    |> List.map to_tuple
  in
  let script_content = read_file script in
  let script_content =
    List.fold_left
      (fun acc (a, b) -> global_replace (regexp_string a) b acc)
      script_content patterns
  in
  let script_content = String.escaped script_content in
  let slurm_command = Printf.sprintf "sbatch %s/tmp/sh" tmp_job_dir in
  let chmod_command = Printf.sprintf "chmod +x %s/tmp.sh" tmp_job_dir in
  create_job_tmp_dir host |> ignore;
  send_string_to_file host script_content |> ignore;
  ssh_command host chmod_command |> ignore;
  ssh_command host slurm_command
