# ---------------------------------------
# ZSHRC Configuration
# ---------------------------------------

function __zshrc_help() {
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
   │                   │ It requires 2 parameters: $(font bg 238) alias_name $(font reset), $(font bg 238) command $(font reset).   │
   │ $(font bg 238) --create-config $(font reset) │ Creates a new configuration file.                    │
   │ $(font bg 238) --multi-alias $(font reset)   │ Creates a new multi-alias script.                    │
   │ $(font bg 238) -u $(font reset)              │ Updates the main $(font underline)zsh.zsh$(font reset) script.                     │
   │ $(font bg 238) -h $(font reset)              │ Shows this help menu.                                │
   └───────────────────└──────────────────────────────────────────────────────┘

   $(font bold underline)Authors$(font reset):     Igor Nunes          https://github.com/ibnunes
                Pedro Cavaleiro     https://github.com/PedroCavaleiro
"
    }

function __zshrc_configure() {
    local ZSHRC_FILE="~/.zshrc"
    [ $# -eq 1 ] && ZSHRC_FILE="$ZSHRC_FILE.d/$1.zsh"
    echo "   Opening $ZSHRC_FILE…"
    nano $ZSHRC_FILE
}

function __zshrc_reload() {
    echo -n "   Reloading zsh configurations… "
    source ~/.zshrc
    echo "$(font fg_green)OK$(font reset)"
}

function __zshrc_alias() {
    if [ $# -eq 2 ]; then
        echo "   Adding new alias: \"$1\" as \"$2\"…"
        echo "# Added at $(date)\nalias $1='$2'" >> ~/.zshrc.d/alias.zsh
        echo "$(font fg_green)OK$(font reset)"
        zshrc -r
    else
        echo "$(font fg_red)Invalid parameters.$(font reset) This option requires 2 parameters: $(font bg 238) alias_name $(font reset), $(font bg 238) command $(font reset)"
    fi
}

function __zshrc_new_config() {
    if [ $# -eq 1 ]; then
        nano ~/.zshrc.d/$1.zsh
    else
        echo "$(font fg_red)Invalid parameters.$(font reset) This option requires 1 parameter: $(font bg 238) file_name $(font reset)."
    fi
}

function __zshrc_multialias() {
    return 0        # Work in progress

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
}

function __zshrc_list() {
    for cfg in ~/.zshrc.d/*.zsh; do
        echo ${$(basename -- "$cfg")%.*}
    done
}

function __zshrc_update() {
    echo -n "   Updating zsh script… "
    curl -s https://raw.githubusercontent.com/ibnunes/zshrc/master/.zshrc.d/zsh.zsh > $HOME/.zshrc.d/zsh.zsh
    echo "$(font fg_green)OK$(font reset)"
    __zshrc_reload
}

function zshrc {
    case $1 in
        ("-c")
            __zshrc_configure $2
            ;;
        ("-r")
            __zshrc_reload
            ;;
        ("-cr")
            __zshrc_configure $2
            __zshrc_reload
            ;;
        ("-a")
            shift; __zshrc_alias $@
            ;;
        ("--create-config")
            shift; __zshrc_new_config $@
            ;;
        ("--multi-alias")
            __zshrc_multialias
            ;;
        ("-l")
            __zshrc_list
            ;;
        ("-u")
            __zshrc_update
            ;;
        ("-h")
            __zshrc_help
            ;;
        (*)
            echo "   $(font fg_red)Invalid arguments.$(font reset)"
            echo "   Here's some help :)\n"
            __zshrc_help
            ;;
    esac
}
