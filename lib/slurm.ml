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

let submit_job script =
  let slurm_command = Printf.sprintf "sbatch %s" script in
  run_command slurm_command
