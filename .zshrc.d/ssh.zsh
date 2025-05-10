# ----------------------------------------
# Open SSH Server
# ----------------------------------------

remote() {
    local SSH_DOMAIN=""     # Customize your intended domain
    local SSH_PORT=22       # Customize your SSH port if applicable (default is 22)

    case $1 in
        ("start"|"stop"|"restart"|"status")
            sudo systemctl $1 ssh sshd
        ;;
        (*)
            local SSH_MODE=
            if [ ! -z $1 ]; then
                SSH_MODE=$1         # e.g. useful for -X option
                shift
            fi
            ssh $SSH_MODE "$1@$SSH_DOMAIN -p $SSH_PORT"
        ;;
    esac
}
