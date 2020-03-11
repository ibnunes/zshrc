# ----------------------------------------
# ZSH Configuration
# ----------------------------------------

function zshrc {
    case $1 in
        "-c")
            eval "nano ~/.zshrc"
            ;;
        "-r")
            eval "source ~/.zshrc"
            ;;
        "-cr")
            eval "zshrc -c"
            eval "zshrc -r"
            ;;
        "-a")
            if [ $# -eq 3 ]; then
                eval 'echo "# Added at $(date)\nalias $2=\"$3\"" >> ~/.zshrc.d/alias.zsh'
                eval "zshrc -r"
                echo "Aliases Updated"
            else
                echo "Wrong number of arguments to create an alias!"
            fi
        ;;
        *)
            echo "Option not available"
            echo "Use \"-c\" to configure and \"-r\" to reload the zsh congiuration"
            echo "You can also add a new alias by using \"-a <alias_name> <command>\""
        ;;
    esac
}
