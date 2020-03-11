# ----------------------------------------
# Open SSH Server
# ----------------------------------------

remote() {
    case $1 in
        "start")
            sudo service ssh start
        ;;
        "stop")
            sudo service ssh stop
        ;;
        "restart")
            sudo service ssh --full-restart
        ;;
        *)
            ssh $1@<server.domain>
        ;;
    esac
}