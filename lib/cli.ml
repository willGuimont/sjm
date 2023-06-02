open Core

(* Remote management *)
let add_remote =
  Command.basic ~summary:"Add a remote ssh server"
    (let%map_open.Command name = anon ("name" %: string)
     and host = anon ("host" %: string) in
     fun () -> State.add_remote name host)

let list_remotes =
  Command.basic ~summary:"Get all remotes"
    (Command.Param.return (fun () ->
         State.get_remotes ()
         |> List.map ~f:(fun (s1, s2) -> s1 ^ " " ^ s2)
         |> List.iter ~f:print_endline))

let remove_host =
  Command.basic ~summary:"Remove a host"
    (let%map_open.Command name = anon ("name" %: string) in
     fun () -> State.remove_remote name)

(* Job management *)
let list_jobs =
  Command.basic ~summary:"List all jobs on host"
    (let%map_open.Command name = anon ("name" %: string) in
     fun () ->
       State.get_host_from_name name |> fun host ->
       match host with
       | Some host -> Slurm.get_jobs host |> List.iter ~f:print_endline
       | None -> print_endline "Host not found")

let clear_job_cache =
  Command.basic ~summary:"Clear the job cache"
    (Command.Param.return (fun () ->
         Slurm.clear_job_cache ();
         print_endline "Cache cleared"))

let clear_remote_job_cache =
  Command.basic ~summary:"Clear the job cache for a remote"
    (let%map_open.Command name = anon ("name" %: string) in
     fun () ->
       State.get_host_from_name name |> fun host ->
       match host with
       | Some host -> Slurm.clear_remote_job_cache host
       | None -> print_endline "Host not found")

let submit_job =
  Command.basic ~summary:"Submit a batch job"
    (let%map_open.Command name = anon ("name" %: string)
     and script = anon ("script" %: string)
     and patterns = anon (sequence ("pattern" %: string)) in
     fun () ->
       State.get_host_from_name name |> fun host ->
       match host with
       | Some host ->
           Slurm.submit_job host script patterns |> List.iter ~f:print_endline
       | None -> print_endline "Host not found")

let cancel_job =
  Command.basic ~summary:"Cancel a job"
    (let%map_open.Command name = anon ("name" %: string)
     and job_id = anon ("job_id" %: string) in
     fun () ->
       State.get_host_from_name name |> fun host ->
       match host with
       | Some host -> Slurm.cancel_job host job_id
       | None -> print_endline "Host not found")

(* Git commands *)
let git_pull =
  Command.basic ~summary:"Pull from git"
    (let%map_open.Command name = anon ("name" %: string)
     and directory = anon ("directory" %: string) in
     fun () ->
       State.get_host_from_name name |> fun host ->
       match host with
       | Some host -> Git.git_pull_remote host directory
       | None -> print_endline "Host not found")

(* Grouping all commands *)
let commands =
  Command.group ~summary:"Slurm Job Manager"
    [
      (* Remote *)
      ("add", add_remote);
      ("ls", list_remotes);
      ("rm", remove_host);
      (* Slurm *)
      ("ps", list_jobs);
      ("run", submit_job);
      ("clr", clear_job_cache);
      ("clr-remote", clear_remote_job_cache);
      ("cancel", cancel_job);
      (* Git *)
      ("pull", git_pull);
    ]
