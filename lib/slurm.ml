open Stdlib

(* Constants *)
let home_dir = Sys.getenv "HOME"
let tmp_path = ".sjm/tmp"
let tmp_dir_local = Printf.sprintf "%s/.sjm/tmp" home_dir
let script_permission = 0o760

(* Actions *)
let get_remote_tmp_dir host =
  let remote_home = Utils.get_remote_home host in
  Printf.sprintf "%s/%s" remote_home tmp_path

let create_tmp_dir host tmp_path_remote =
  let mk_cmd = Printf.sprintf "mkdir -p %s" in
  let cmd_local = mk_cmd tmp_dir_local in
  let cmd_remote = mk_cmd tmp_path_remote in
  Utils.run_command cmd_local |> ignore;
  Utils.ssh_command host cmd_remote |> ignore

let get_jobs host =
  let user = String.split_on_char '@' host |> List.hd in
  Utils.ssh_command host (Printf.sprintf "squeue -u %s" user)

let clear_job_cache () =
  Utils.run_command (Printf.sprintf "rm -r %s/*" tmp_dir_local) |> ignore

let clear_remote_job_cache host =
  let tmp_path_remote = get_remote_tmp_dir host in
  Utils.ssh_command host (Printf.sprintf "rm -r %s/*" tmp_path_remote) |> ignore

let submit_job host script_path replace_patterns =
  let script_content = Utils.read_file script_path in
  let script_content =
    Utils.replace_in_string script_content replace_patterns
  in

  let script_name = Printf.sprintf "tmp_%d.sh" (int_of_float (Unix.time ())) in
  let local_script_path = Printf.sprintf "%s/%s" tmp_dir_local script_name in
  let tmp_path_remote = get_remote_tmp_dir host in
  let remote_script_path = Printf.sprintf "%s/%s" tmp_path_remote script_name in

  let sbatch_command = Printf.sprintf "sbatch %s" remote_script_path in

  create_tmp_dir host tmp_path_remote;

  Utils.write_script local_script_path script_content;
  Unix.chmod local_script_path script_permission;

  Utils.send_string_to_file host local_script_path remote_script_path;
  Utils.ssh_command host sbatch_command

let cancel_job host job_id =
  Utils.ssh_command host (Printf.sprintf "scancel %s" job_id) |> ignore
