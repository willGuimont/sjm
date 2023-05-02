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

let get_host_from_name =
  Command.basic ~summary:"Get host from name"
    (let%map_open.Command name = anon ("name" %: string) in
     fun () ->
       State.get_host_from_name name
       |> Option.value_exn ~message:"No host found for this name"
       |> print_endline)

let remove_host =
  Command.basic ~summary:"Remove a host"
    (let%map_open.Command name = anon ("name" %: string) in
     fun () -> State.remove_remote name)

(* Grouping all commands *)
let commands =
  Command.group ~summary:"Slurm Job Manager"
    [
      ("add", add_remote);
      ("list", list_remotes);
      ("get", get_host_from_name);
      ("rm", remove_host);
    ]
