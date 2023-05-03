open Core

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
    (let%map_open.Command name = anon ("name" %: string) in
     fun () ->
       State.get_host_from_name name |> fun host ->
       match host with
       | Some host -> Slurm.clear_job_cache host |> ignore
       | None -> print_endline "Host not found")

let batch_job =
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

(* Grouping all commands *)
let commands =
  Command.group ~summary:"Slurm Job Manager"
    [
      ("add", add_remote);
      ("ls", list_remotes);
      ("rm", remove_host);
      ("ps", list_jobs);
      ("start", batch_job);
      ("clear", clear_job_cache);
    ]
