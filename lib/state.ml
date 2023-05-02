let home_dir = Sys.getenv "HOME"
let config_dir = home_dir ^ "/.sjm"
let config_path = config_dir ^ "/config"
let permission = 0o777

let create_config_dir () =
  if not (Sys.file_exists config_dir) then Sys.mkdir config_dir permission

let add_remote name url =
  create_config_dir ();
  let oc =
    open_out_gen [ Open_creat; Open_text; Open_append ] permission config_path
  in
  output_string oc (Printf.sprintf "%s %s\n" name url);
  close_out oc

let get_remotes () =
  let ic = open_in config_path in
  let rec loop acc =
    try
      let line = input_line ic in
      let name, url = Scanf.sscanf line "%s %s" (fun n u -> (n, u)) in
      loop ((name, url) :: acc)
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
  let oc = open_out config_path in
  List.iter
    (fun (n, h) -> output_string oc (Printf.sprintf "%s %s\n" n h))
    remotes;
  close_out oc
