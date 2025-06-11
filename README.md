# zshrc

Personalized configuration for `zsh`.

* **License:** [The Unlicense](LICENSE.md)
* **Authors:** [Igor Nunes](https://github.com/ibnunes), [Pedro Cavaleiro](https://github.com/PedroCavaleiro)

This project was created as a personal repository to have everything ready to use for whenever we format our PCs. However, we figured it could be useful for more people because why the hell not.

Enjoy it!


## Organization

A small piece of code is added to `.zshrc` that goes through the folder `.zshrc.d` in search of `*.zsh` files and sources them. This will expose the new *zshrc* utility functions to your current *zsh* session.

Each `*.zsh` file contains scripts/functions for specific purposes.

```
/home/you
   ├── .zshrc.d
   |      ├── alias.zsh
   |      ├── escape.zsh
   |     ...
   |      └── zsh.zsh
   └── .zshrc
```


## Installation

### Using *setup.zsh*

This is the **recommended method**.

To install *zshrc* run the following command in *zsh*:

`zsh -c "$(curl -fsSL https://raw.githubusercontent.com/ibnunes/zshrc/master/setup.zsh)"`

More information available on the [wiki](https://github.com/ibnunes/zshrc/wiki/Installation). You may check the [releases](https://github.com/ibnunes/zshrc/releases/tag/1.0.0) page as well.


### Manual installation

1. Add the code of our [`.zshrc`](.zshrc) to your own resource file (using any text editor of your choice, like `nano`, `vi` or even vscode):
   ```bash
   nano ~/.zshrc
   ```

2. Create the folder `zshrc.d` on your home directory:
   ```bash
   mkdir ~/.zshrc.d
   ```

3. Copy the [`*.zsh` scripts](.zshrc.d) you find useful to the newly created `~/.zshrc.d` directory.

4. Reload *zsh* configuration using:
   ```bash
   source ~/.zshrc
   ```
   If you already have the `zsh.zsh` file and it was **previously loaded**, you can use the command `zshrc -r` instead.


## Usage

### *zshrc* assisted management

*zshrc* offers the command `zshrc` to manage some of the most essential functionalities.

| Option | Description |
| --- | --- |
| `-l`              | Lists all loaded configurations.                                                                      |
| `-c`              | Opens a given configuration file. If no file name is passed, `~/.zshrc` will be opened.               |
| `-r`              | Reloads *zsh* configurations.                                                                         |
| `-cr`             | Performs `-c` followed by `-r`.                                                                       |
| `-a`              | Adds a new *alias* to the *alias* configuration file. Requires 2 parameters: `alias_name`, `command`. |
| `--create-config` | Creates a new configuration file. Requires 1 parameter: `file_name`.                                  |
| `--multi-alias`   | Creates a new multi-alias script.                                                                     |
| `-u`              | Updates *zshrc* and its internal dependencies.                                                        |
| `-h`              | Shows embedded help.                                                                                  |


### Available scripts

*zshrc* includes the following scripts:

| Script | Provides |
| --- | --- |
| *Essential* |
| [`zsh`](.zshrc.d/zsh.zsh)                   | *zshrc*'s assisted management. |
| [`alias`](.zshrc.d/alias.zsh)               | User-defined aliases. |
| [`blkidf`](.zshrc.d/blkidf.zsh)             | Formatted `blkid` output (as table, JSON and other 9 formats). |
| [`hdd`](.zshrc.d/hdd.zsh)                   | Disk monitoring and management. |
| [`hdd_external`](.zshrc.d/hdd_external.zsh) | External commands to be invoked by `hdd`. **It needs to be manually edited**. |
| *Optional* |
| [`mobaxterm`](.zshrc.d/mobaxterm.zsh)       | Constants necessary for *MobaXterm* users. |
| [`ssh`](.zshrc.d/ssh.zsh)                   |  |
| *Developer* |
| [`cc`](.zshrc.d/cc.zsh)                     | Convenience options for `gcc`. |
| [`cpp`](.zshrc.d/cpp.zsh)                   | Convenience options for `g++`. |
| [`gl`](.zshrc.d/gl.zsh)                     | Convenience funtions to compile OpenGL and Vulkan projects in Linux. |
| *Self-dependencies* |
| [`escape`](.zshrc.d/escape.zsh)             | Shell font personalization for all other scripts. |
| [`utils`](.zshrc.d/utils.zsh)               | Utilitary functions. |


### Commands provided out-of-the-box

| Command | Description | Observations |
| --- | --- | --- |
| `zsh` | The `zshrc` Manager |  |
| **General** |
| `blkidf` | Formatted `blkid` command. | 11 possible formats: Table, CSV, Markdown, JSON, NDJSON, YAML, TOML, INI, SQL, HTML, XML. |
| `font` | Formatted text using ANSI Escape Codes. | |
| `hdd` | Collection of HDD management utilities. | There are "external" commands &mdash; in [`hdd_external.zsh`](.zshrc.d/hdd_external.zsh) &mdash; which must be customized by you before use. |
| `remote` | Manages `sshd` service or initiates remote SSH session. | The [`ssh.zsh`](.zshrc.d/ssh.zsh) script must be customized by you before use. |
| **Package manager aliases** |  | Only compatible with package managers similar to `apt`. |
| `update`     | Alias for `sudo $pkg update`     | Where `$pkg` is the package manager (default: `apt`). |
| `upgrade`    | Alias for `sudo $pkg upgrade`    | Idem. |
| `upall`      | Alias for `update && upgrade`    | Idem. |
| `install`    | Alias for `sudo $pkg install`    | Idem. |
| `remove`     | Alias for `sudo $pkg remove`     | Idem. |
| `autoremove` | Alias for `sudo $pkg autoremove` | Idem. |
| **For developers** |
| `yesno` | Command to get a yes/no answer from the user in zsh scripts. | Not tested for other shells. |
| `runcc` | Alias for `gcc` with a series of flags and C17 by default. | Can be customzied in [cc.zsh](.zshrc.d/cc.zsh): we provide auxiliary functions for the most common C Standards. |
| `runcpp` | Alias for `g++` with a series of flags and C++20 by default. | Can be customzied in [cpp.zsh](.zshrc.d/cpp.zsh): we provide auxiliary functions for the most common C++ Standards. |
| `rungl` | Alias for `g++` to compile a project with OpenGL. | Requires the presence of a collection of OpenGL libraries and others related. |
| `runvk` | Alias for `g++` to compile a project with Vulkan. | Requires the presence of a collection of Vulkan libraries and others related. |


## Contribution

Anyone can contribute and/or fork from this repository.

**We invite you to contribute directly to this repository**, though, in order to mantain it as a centralized repo with plenty of options for everyone.

Create new `*.zsh` files to add to the `.zshrc.d` directory.

### List of Contributions

| Contributor | Contributions |
| --- | --- |
| [Igor Nunes](https://github.com/ibnunes) | Original project; *hdd* and *blkidf* commands |
| [Pedro Cavaleiro](https://github.com/PedroCavaleiro) | Original project; *zsh.zsh* main script; Setup |
