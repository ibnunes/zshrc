# zshrc

Personalized configuration of `zsh`.

It has nothing really special about it. It was created as a personal repository to have everything ready to use for whenever we format our PCs. However, we figured it could be useful for more people because why the hell not.

Enjoy it!

* **Authors:** Igor Nunes, Pedro Cavaleiro
* **License:** [The Unlicense](LICENSE.md)


## Organization

The file `.zshrc` contains a small script that runs through the folder `.zshrc.d` in search of `*.zsh` files and runs them.

Each `*.zsh` file contains scripts for specific purposes.

## Installing without cloning

To install the scripts without cloning just enter the following command into the ZShell

`zsh -c "$(curl -fsSL https://raw.githubusercontent.com/ibnunes/zshrc/master/setup.zsh)"`

More information available on the [wiki](https://github.com/ibnunes/zshrc/wiki/Installation) or check the [releases](https://github.com/ibnunes/zshrc/releases/tag/1.0.0) page

## How to use

1. Add the last bit of the `.zshrc` to your own resource file (using any text editor of your choice, like `nano`, `vi` or even vscode):
   ```bash
   nano ~/.zshrc
   ```
2. Create the folder `zshrc.d` with the command:
   ```bash
   mkdir ~/.zshrc.d
   ```
3. Copy the `*.zsh` files you find useful to this folder.
4. Reload the configurations of the shell using:
   ```bash
   source ~/.zshrc
   ```
   If you already have the `zsh.zsh` file and it was **previously loaded**, you can use the command
   ```bash
   zshrc -r
   ```
   instead.


## Contribution

Anyone can contribute and/or fork from this repository.

**We invite you to contribute directly to this repository**, though, in order to mantain it as a centralized repo with plenty of options for everyone.

Create new `*.zsh` files to add to the `.zshrc.d` folder.
