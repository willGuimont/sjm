let git_pull_remote host directory =
  Utils.ssh_command host (Printf.sprintf "cd %s && git pull" directory)
  |> ignore
