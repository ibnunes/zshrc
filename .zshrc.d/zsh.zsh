# ---------------------------------------
# ZSH Configuration
# ---------------------------------------

function zshrc {
    function zshrc_help() {
        echo "   $(font bold fg_cyan)                                   zshrc                                    $(font reset)
   ────────────────────────────────────────────────────────────────────────────
   $(font bold underline)Usage$(font reset):  $(font bg 238) zshrc option [parameters] $(font reset)

   ┌───────────────────┬──────────────────────────────────────────────────────┐
   │ $(font bold)OPTION$(font reset)            │ $(font bold)DESCRIPTION$(font reset)                                          │
   ├───────────────────┼──────────────────────────────────────────────────────┤
   │ $(font bg 238) -l $(font reset)              │ Lists all the loaded configurations.                 │
   │ $(font bg 238) -c $(font reset)              │ Opens the configuration file. If no configuration    │
   │                   │ name is passed, $(font underline)~./zshrc$(font reset) will be opened.             │
   │ $(font bg 238) -r $(font reset)              │ Reloads zsh configurations.                          │
   │ $(font bg 238) -cr $(font reset)             │ Performs $(font bg 238) -c $(font reset) followed by $(font bg 238) -r $(font reset).                      │
   │ $(font bg 238) -a $(font reset)              │ Adds a new alias to the alias configuration file.    │
   │                   │ It requires two parameters: $(font bg 238) alias_name $(font reset), $(font bg 238) command $(font reset). │
   │ $(font bg 238) --create-config $(font reset) │ Creates a new configuration file.                    │
   │ $(font bg 238) --multi-alias $(font reset)   │ Creates a new multi-alias script.                    │
   │ $(font bg 238) -u $(font reset)              │ Updates the main $(font underline)zsh.zsh$(font reset) script.                     │
   │ $(font bg 238) -h $(font reset)              │ Shows this help menu.                                │
   └───────────────────└──────────────────────────────────────────────────────┘
"
    }

    case $1 in
        ("-c")
            if [ $# -eq 2 ]; then
                eval "nano ~/.zshrc.d/$2.zsh"
            else
                eval "nano ~/.zshrc"
            fi
            ;;
        ("-r")
            eval "source ~/.zshrc"
            echo "zshrc updated"
            ;;
        ("-cr")
            eval "zshrc -c $2"
            eval "zshrc -r"
            ;;
        ("-a")
            if [ $# -eq 3 ]; then
                eval 'echo "# Added at $(date)\nalias $2=\"$3\"" >> ~/.zshrc.d/alias.zsh'
                eval "zshrc -r"
            else
                echo "This option requires two parameters run \"zshrc -h\"for help"
            fi
            ;;
        ("--create-config")
            if [ $# -eq 2 ]; then
                eval "nano ~/.zshrc.d/$2.zsh"
            else
                echo "This option requires one parameter run \"zshrc -h\"for help"
            fi
            ;;
        ("--multi-alias")
            read  "?Enter the multi alias name: " multiAliasName
            echo "# ----------------------------------------\n# $multiAliasName navigation shortcuts\n# ----------------------------------------" > $HOME/.zshrc.d/$multiAliasName.zsh
            echo "\nfunction $multiAliasName {\n\tcase \$1 in" >> $HOME/.zshrc.d/$multiAliasName.zsh
            exitFlag="n"
            while [ $exitFlag = "n" ]
            do
                read "?Alias: " aliasName
                read "?Path: " aliasPath
                echo "\t\t\"$aliasName\") eval \"cd $aliasPath\"" >> $HOME/.zshrc.d/$multiAliasName.zsh
                echo "\t\t;;" >> $HOME/.zshrc.d/$multiAliasName.zsh
                read "?End multi alias script creation? (y/n) " exitFlag
            done
            echo "\tesac\n}" >> $HOME/.zshrc.d/$multiAliasName.zsh
            eval "zshrc -r"
            ;;
        ("-l")
            for cfg in ~/.zshrc.d/*.zsh; do
                echo ${$(basename -- "$cfg")%.*}
            done
            ;;
        ("-u")
            echo "Updating zsh script..."
            rm -f "$HOME"/.zshrc.d/zsh.zsh
            eval "curl -s https://raw.githubusercontent.com/thoga31/zshrc/master/.zshrc.d/zsh.zsh -o "$HOME"/.zshrc.d/zsh.zsh"
            eval "zshrc -r"
            echo "zsh script updated"
            ;;
        ("-h")
            zshrc_help
            ;;
        (*)
            eval "zshrc -h"
            ;;
    esac
}
