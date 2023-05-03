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
# Submit job on remote
sjm run <name> <script_name> [list of replace patterns of the form "pattern=value" that will be place each $pattern in the script by value]
# Clear tmp jobs cache
sjm clr
# Clear tmp jobs cache on host
sjm clr-remote <name>
```

## Example

```bash
sjm add mycluster wigum@123.456.789.012
# See test_job.sh for an example of a job script
sjm run mycluster test_job.sh NUMBER_GPU=2 CONFIG=my_config.yml
sjm ps mycluster
```
