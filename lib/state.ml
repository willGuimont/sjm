(* Constants *)
let home_dir = Sys.getenv "HOME"
let config_dir = home_dir ^ "/.sjm"
let hosts_path = config_dir ^ "/hosts"
let keys_path = config_dir ^ "/keys"
let permission_dir = 0o760
let permission_file = 0o660

(* Helper functions *)
let append_to_config path content =
  let oc =
    open_out_gen [ Open_creat; Open_text; Open_append ] permission_file path
  in
  output_string oc content;
  close_out oc

let create_config_dir () =
  if not (Sys.file_exists config_dir) then Sys.mkdir config_dir permission_dir;
  if not (Sys.file_exists hosts_path) then append_to_config hosts_path "";
  if not (Sys.file_exists keys_path) then append_to_config keys_path ""

(* Actions *)

let add_remote name host =
  create_config_dir ();
  if String.contains host '@' then
    append_to_config hosts_path (Printf.sprintf "%s %s\n" name host)
  else print_endline "Invalid host format. Use user@host"

let get_remotes () =
  create_config_dir ();
  let ic = open_in hosts_path in
  let rec loop acc =
    try
      let line = input_line ic in
      let name, host =
        Scanf.sscanf line "%s %s" (fun name host -> (name, host))
      in
      loop ((name, host) :: acc)
    with End_of_file -> acc
  in
  let remotes = loop [] in
  close_in ic;
  remotes

let get_host_from_name name =
  let remotes = get_remotes () in
  let rec loop = function
    | [] -> None
    | (n, h) :: _ when n = name -> Some h
    | _ :: t -> loop t
  in
  loop remotes

let remove_remote name =
  let remotes = get_remotes () in
  let rec loop = function
    | [] -> []
    | (n, _) :: t when n = name -> loop t
    | h :: t -> h :: loop t
  in
  let remotes = loop remotes in
  let oc = open_out hosts_path in
  List.iter
    (fun (n, h) -> output_string oc (Printf.sprintf "%s %s\n" n h))
    remotes;
  close_out oc
