# zshrc

Personalized configuration of `zsh`.

* **Authors:** [Igor Nunes](https://github.com/ibnunes), [Pedro Cavaleiro](https://github.com/PedroCavaleiro)
* **License:** [The Unlicense](LICENSE.md)


## Motivation

This project was created as a personal repository to have everything ready to use for whenever we format our PCs. However, we figured it could be useful for more people because why the hell not.

Enjoy it!


## Organization

A small piece of code is added to `.zshrc` that goes through the folder `.zshrc.d` in search of `*.zsh` files and sources them. This will expose the new *zshrc* utility functions to your current *zsh* session.

Each `*.zsh` file contains scripts/functions for specific purposes.

```
/home/you
   ├── .zshrc.d
   │      ├── alias.zsh
   │      ├── escape.zsh
   │     ...
   │      └── zsh.zsh
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


## Contribution

Anyone can contribute and/or fork from this repository.

**We invite you to contribute directly to this repository**, though, in order to mantain it as a centralized repo with plenty of options for everyone.

Create new `*.zsh` files to add to the `.zshrc.d` directory.

### List of Contributions

| Contributor | Contributions |
| --- | --- |
| [Igor Nunes](https://github.com/ibnunes) | Original project, *hdd* scripts |
| [Pedro Cavaleiro](https://github.com/PedroCavaleiro) | Original project, *zsh.zsh* main script, setup |
