This project defines configs for various tools which, together, form a terminal-based development environment.

GNU Stow will be used to manage symlinks that place each config in the appropriate place in the file system.

A README file in the root should explain the project at a high level and list all required dependencies. There should also be a shell script in the root which will install all required dependencies.

Once all dependencies are installed, the user should be able to `cd` into the root directory and run `stow <module>` where `<module>` is the name of one of the configured tools (and the directory in which that tool is configured) to correctly set up the symlinks for that module. E.g. `stow nvim`.

This project should be as modular as possible. A user should be able to install only the modules they want. Therefore the root-level install script should actually call a separate install script per module, each located within the relevant module, which just installs that module's dependencies.

Where possible, the catpuccin theme will be used for all tools.

Each config file should start with a comment that shows the filepath it will be symlinked to.

Each module should also include instructions for uninstallation.

Assume that there are no config changes or further plugins added to these tools outside what is managed via this repository. Therefore there is no need to document options, how they'd be removed etc.