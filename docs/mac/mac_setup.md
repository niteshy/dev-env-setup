This guide provide the step-wise flow for setting up the new Mac OS (especially for M3 Mac)

# Download development tools
1. VS code

## General Setup
1. Install brew (a package manager) from [brew.sh](https://brew.sh/)
   ```
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    ```

1. Bash Setup

    1. If you prefer working using Bourne Bash shell, then install bash using brew
        ```
        brew install bash
        ```
        Note: The new bash is installed via brew at `/opt/homebrew/bin/bash`. We need to add it to the list of permitted shells:
        ```
        echo $(brew --prefix)/bin/bash | sudo tee -a /private/etc/shells
        ```
    1. More details why use Bourne bash? Read following articles
        - https://dev.to/w3cj/setting-up-a-mac-for-development-3g4c
        - https://github.com/renekreijveld/macOS-Local-Development-Setup/blob/master/setup.arm.md#optional-bash-update
    1. Few handy commands
        1. To check which shell is running, `echo $SHELL`
        1. To check where bash is installed, `which bash`

1. Java Setup
    1. Install jenv for java `brew install jenv`
    1. Install openjdk17 version via brew `brew install openjdk@17`. It will install Java at the `/opt/homebrew/opt/` path.
    1. Link brew jdk path to system path
        ```
        sudo ln -sfn /opt/homebrew/opt/openjdk@17/libexec/openjdk.jdk /Library/Java/JavaVirtualMachines/openjdk-17.jdk
        ```
    1. To default load the Jenv into respective shells
        1. For bash
            ```
            echo eval "$(jenv init -)" >> ~/.bash_profile
            ```
        1. For zsh
            ```
            echo eval "$(jenv init -)" >> ~/.zshrc
            ```
    1. To check the system install java versions
        ```
        /usr/libexec/java_home -V
        ```

1. Customize Terminal
    1. Open terminal
    1. To customize our bash install cmb `src/scripts/install-customize-my-bash.sh`, inspired from [oh-my-bash](https://github.com/ohmybash/oh-my-bash)
    Note: It will replace your `~/.bashrc`, don't worry the next step will further overwrite it.
    1. Customize vim, we are going to use [vim-plug](https://github.com/junegunn/vim-plug) to install the plugin in vim.
   There are few useful [tips](https://github.com/junegunn/vim-plug/wiki/tips#automatic-installation)
    1. Run the setup `bash src/scripts/setup-mac.sh`