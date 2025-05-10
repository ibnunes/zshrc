# ---------------------------------------
# ZSHRC Configuration
# ---------------------------------------

ZSHRC_VERSION="1.4.0-beta"

function __zshrc_help() {
    echo "   $(font bold fg_cyan)                                   zshrc                                    $(font reset)
   ────────────────────────────────────────────────────────────────────────────
   $(font bold underline)Usage$(font reset):  $(font bg 238) zshrc option [parameters] $(font reset)                               $(font bold fg_cyan)$ZSHRC_VERSION$(font reset)

   ┌───────────────────┬──────────────────────────────────────────────────────┐
   │ $(font bold)OPTION$(font reset)            │ $(font bold)DESCRIPTION$(font reset)                                          │
   ├───────────────────┼──────────────────────────────────────────────────────┤
   │ $(font bg 238) -l $(font reset)              │ Lists all the loaded configurations.                 │
   │ $(font bg 238) -c $(font reset)              │ Opens the configuration file. If no configuration    │
   │                   │ name is passed, $(font underline)~./zshrc$(font reset) will be opened.             │
   │ $(font bg 238) -r $(font reset)              │ Reloads zsh configurations.                          │
   │ $(font bg 238) -cr $(font reset)             │ Performs $(font bg 238) -c $(font reset) followed by $(font bg 238) -r $(font reset).                      │
   │ $(font bg 238) -a $(font reset)              │ Adds a new alias to the alias configuration file.    │
   │                   │ Requires 2 parameters: $(font bg 238) alias_name $(font reset), $(font bg 238) command $(font reset).      │
   │ $(font bg 238) --create-config $(font reset) │ Creates a new configuration file.                    │
   │                   │ Requires 1 parameter: $(font bg 238) file_name $(font reset).                   │
   │ $(font bg 238) --multi-alias $(font reset)   │ Creates a new multi-alias script.                    │
   │ $(font bg 238) -u $(font reset)              │ Updates zshrc and its internal dependencies.         │
   │ $(font bg 238) -h $(font reset)              │ Shows this help menu.                                │
   └───────────────────┴──────────────────────────────────────────────────────┘

     $(font bold underline)Contribute in$(font reset):                         https://github.com/ibnunes/zshrc
           $(font bold underline)Authors$(font reset):      Igor Nunes         https://github.com/ibnunes
                         Pedro Cavaleiro    https://github.com/PedroCavaleiro
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
    echo "\n     $(font bold fg_cyan)ZSHRC multi-alias creator$(font reset)
   ┌───────────────────────────────────────────────────────────────────────────
   │ A multi-alias is a command with 1 parameter that allows one to redirect to
   │ folders with ease.
   │ The multi-alias will be used as such: $(font bg 238) command parameter $(font reset)
   │ Each $(font bg 238) parameter $(font reset) is defined as a different folder to go to.
   │ The name of the multi-alias will be the same as the $(font bg 238) command $(font reset).
"

    local multiAliasName=
    echo -n "   Enter the $(font underline)multi-alias$(font reset) name (this will be the $(font bg 238) command $(font reset)): "
    read multiAliasName

    local multiAliasFileContent="# ----------------------------------------
# $multiAliasName navigation shortcuts
# ----------------------------------------

function $multiAliasName {
    case \$1 in"

    local aliasName=
    local aliasPath=
    local exitFlag=0
    while [ $exitFlag -eq 0 ]; do
        echo -n "\n   Provide the $(font underline)alias$(font reset) (this will be a $(font bg 238) parameter $(font reset)): "
        read aliasName
        echo -n "   Provide the $(font underline)path$(font reset) (this is where you want to $(font underline)cd$(font reset) when prompting $(font bg 238) $multiAliasName $aliasName $(font reset)): "
        read aliasPath

        multiAliasFileContent="$multiAliasFileContent
        (\"$aliasName\")
            cd \"$aliasPath\"
            ;;"

        echo "\n   $(font bg 238) $multiAliasName $aliasName $(font reset) will redirect to $(font underline)$aliasPath$(font reset).\n"
        yesno "   Add more aliases to $(font bg 238) $multiAliasName $(font reset)?"
        exitFlag=$?
    done

    multiAliasFileContent="$multiAliasFileContent
    esac
}"

    echo $multiAliasFileContent > $HOME/.zshrc.d/$multiAliasName.zsh
    echo "   ────────────────────────────────────────────────────────────────────────────\n"
    __zshrc_reload
}

function __zshrc_list() {
    for cfg in ~/.zshrc.d/*.zsh; do
        echo ${$(basename -- "$cfg")%.*}
    done
    unset -v cfg
}

function __zshrc_update() {
    ZSHRC_FILES=("zsh" "hdd" "utils")

    echo "\n     $(font bold fg_cyan)ZSHRC updater$(font reset)
   ┌───────────────────────────────────────────────────────────────────────────
   │ ZSHRC will check for updates.
   │
   │ Since all zshrc files can be freely modified by the user, only these
   │ files will be automatically checked for updates since they provide
   │ the main script and its dependencies: $(font bg 238 bold) ${^ZSHRC_FILES} $(font reset).
   │
   │ $(font bold bg_yellow) ATTENTION! $(font reset) This action is $(font fg_yellow bold)irreversible$(font reset)!
"

    yesno "   $(font bold bg_red) CAUTION! $(font reset) Do you want to proceed?"
    if [ $? -eq 0 ]; then
        local ZSH_LATEST=
        echo "\n   Updating dependencies…"
        for f in $ZSHRC_FILES; do
            echo "   Fetching latest $(font underline)$f.zsh$(font reset) script…"
            ZSH_LATEST=$(curl -s "https://raw.githubusercontent.com/ibnunes/zshrc/master/.zshrc.d/$f.zsh")
            if [ ! -z $ZSH_LATEST ] && [[ $ZSH_LATEST != "$(cat $HOME/.zshrc.d/$f.zsh)" ]]; then
                echo -n "      Updating $(font underline)$f.zsh$(font reset) script… "
                echo $ZSH_LATEST > $HOME/.zshrc.d/$f.zsh
                echo "$(font fg_green)OK$(font reset)"
            else
                echo "      Nothing to do. $(font underline)$f.zsh$(font reset) is up to date."
            fi
        done
        unset -v f
        echo "   $(font fg_green)Update finalized.$(font reset) zshrc will be now reloaded…\n"
        __zshrc_reload
    else
        echo "\n   $(font yellow)Operation cancelled$(font reset) by the user.\n"
    fi
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
