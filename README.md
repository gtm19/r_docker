# R Docker / VS Code Development Container setup

# Pre-requisites

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
