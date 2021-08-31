# R Docker / VS Code Development Container setup

# Pre-requisites

## `.Rprofile`

Note that, once `renv` is activated, useful system R libraries like `languageserver` will not be available. As such, much like `renv` is installed on startup of the R terminal if not available (due to the `source("renv/activate.R")` call which `renv` places in the `.Rprofile` on initialisation), I have (following Eric Nantz's [example](https://github.com/rpodcast/r_dev_projects/blob/master/.devcontainer/README.md#using-renv-with-vs-code)) added some additional code to the `.Rprofile` which will install `languageserver` and `httpgd` if they are missing:

```r
# setup if using with vscode and R plugin
if (Sys.getenv("TERM_PROGRAM") == "vscode") {
    source(file.path(Sys.getenv(if (.Platform$OS.type == "windows") "USERPROFILE" else "HOME"), ".vscode-R", "init.R"))
}

source("renv/activate.R")

if (Sys.getenv("TERM_PROGRAM") == "vscode") {
    # obtain list of packages in renv library currently
    project <- renv:::renv_project_resolve(NULL)
    lib_packages <- names(unclass(renv:::renv_diagnostics_packages_library(project))$Packages)

    # detect whether key packages are already installed
    # was: !require("languageserver")
    if (!"languageserver" %in% lib_packages) {
        message("installing languageserver package")
        renv::install("languageserver")
    }

    if (!"httpgd" %in% lib_packages) {
        message("installing httpgd package")
        renv::install("httpgd")
    }
}

```

## `ssh-agent`

If you authenticate `git` operations using SSH, you will need to ensure that `ssh-agent` is running locally, and that the relevant keys have been added to it, so that the VS Code Remote Container extension can forward it to the dev container.

The guide for setting this up can be found [here](https://code.visualstudio.com/docs/remote/containers#_using-ssh-keys).

However, for me, this amounted to doing the following.

### Install `socat` on host WSL(2)

This will be required if using WSL:

```sh
sudo apt-get update && sudo apt-get install -y socat
```

### Add the following to my `~/.zprofile` (since I am using `zsh`)

```sh
# Initialise ssh-agent
if [ -z "$SSH_AUTH_SOCK" ]; then
   # Check for a currently running instance of the agent
   RUNNING_AGENT="`ps -ax | grep 'ssh-agent -s' | grep -v grep | wc -l | tr -d '[:space:]'`"
   if [ "$RUNNING_AGENT" = "0" ]; then
        # Launch a new instance of the agent
        ssh-agent -s &> $HOME/.ssh/ssh-agent
   fi
   eval `cat $HOME/.ssh/ssh-agent`
fi

# Add github key to ssh-agent
ssh-add ~/.ssh/id_ed25519
```

If your SSH key is called something different, amend the last line accordingly.

If using `bash`, this instead needs to go in your `~/.bash_profile`.

Once this is done, you'll have to restart your WSL terminal instance.

### Checking it works

To check it works, open the dev container in VS Code, and in the integrated console, run:

```sh
ssh -T git@github.com
```

You should see something like:

```
Hi gtm19! You've successfully authenticated, but GitHub does not provide shell access.
```

# Using the dev container

To use the dev container, clone this repo, and open it in VS Code:

```
git clone git@github.com:gtm19/r_docker.git
cd r_docker
code .
```

VS Code should prompt you to re-open the folder in the dev container. You'll want to say yes.
