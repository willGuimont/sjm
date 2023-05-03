(lang dune 3.7)

(name sjm)

(generate_opam_files true)

(source
 (github willGuimont/sjm))

(authors "William Guimont-Martin")

(maintainers "William Guimont-Martin")

(license MIT)

(documentation https://github.com/willGuimont/sjm)

(package
 (name sjm)
 (synopsis "Slurm Job Manager")
 (description "Allows you to manage your Slurm jobs from the command line.")
 (depends ocaml dune ANSITerminal core core_unix ppx_tools ppx_jane)
 (tags
  (cli tool slurm manager deep-learning)))

; See the complete stanza docs at https://dune.readthedocs.io/en/stable/dune-files.html#dune-project
