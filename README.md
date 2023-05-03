# sjm: **S**LURM **J**ob **M**anager

Manage SLURM jobs on multiple clusters easily.

## Installation

```bash
opam install .
```

## Usage

```bash
# Add remote (ssh-copy-id is required)
sjm add <name> <user@host>
# List remotes
sjm ls
# Remove remote
sjm rm <name>
# List jobs on remote
sjm ps <name>
```
