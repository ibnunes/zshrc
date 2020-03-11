# zshrc

Personalized configuration of `zsh`.

It has nothing really special about it. It was created as a personal repository to have everything ready to use for whenever I format my PCs. However, I figured it could be useful for more people because why the hell not.

Enjoy it!

* **Author:** Igor Nunes, a.k.a. thoga31
* **License:** [The Unlicense](LICENSE.md)


## Organization

The file `.zshrc` contains a small script that runs through the folder `.zshrc.d` in search of `*.zsh` files and runs them.

Each `*.zsh` file contains scripts for specific purposes.


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

**I invite you to contribute directly to this repository**, though, in order to mantain it as a centralized repo with plenty of options for everyone.

Create new `*.zsh` files to add to the `.zshrc.d` folder.
