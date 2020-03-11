# ----------------------------------------
# Personal navigation shortcuts
# ----------------------------------------

alias home='cd ~/HOME'

ubi() {
    case $1 in
        "tc")
            eval "cd ~/TCOMP"
            ;;
        "so")
            eval "cd ~/SO"
            ;;
    esac
}
