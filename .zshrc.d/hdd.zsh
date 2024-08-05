function hdd() {
    echo ""     # Just some spacing for looks

    # Manually added exceptions (leave as "" if none is required).
    # Add exceptions separated by spaces (e.g. "sdb sdf sdh").
    # Do NOT precede with "/dev/", it'll be added where necessary.
    local HDD_EXCEPTIONS=""

    # To save partition labels
    declare -A HDD_PARTITIONS


    # Automatically add SSDs as exceptions
    function hdd_add_ssd_as_exception() {
        local ARRSSD=(${(s/ /)}$(
            lsblk -d -o NAME,ROTA         |
            grep -E "sd[a-z].*0"          |
            sed -re 's/(sd[a-z]).*$/\1/g' |
            tr '\n' ' '
        ))
        local EXCEPT=(${(s/ /)HDD_EXCEPTIONS})
        for ssd in $ARRSSD; do
            if (( ! ${EXCEPT[(I)$ssd]} )); then
                HDD_EXCEPTIONS+=" $ssd"
            fi
        done
    }


    # Get partition labels for all drives
    function hdd_get_partition_labels() {
        local STRPAIRS=$(
            lsblk -o NAME,LABEL                                 |
            grep -E 'sd[a-z][0-9]'                              |
            sed -re 's/.*(sd[a-z])[0-9]/\1/g' -e 's/  */§/g'    |
            tr '\n' ' ')
        local ARRPAIRS=(${(s/ /)STRPAIRS})
        for pair in $ARRPAIRS; do
            key="/dev/${pair%%§*}"
            value=${pair##*§}
            HDD_PARTITIONS[$key]+="$value, "
            # Last comma will be trimmed directly in output
        done
    }


    # Prints drives given by argument separated by spaces; removes preceding "/dev/"
    function hdd_printf() {
        if [ -z $1 ]; then
            echo "None"
        else
            echo "$@"           |
            sed -e 's/|/ /g'    \
                -e 's/\\//g'    |
            sed -e 's/  */, /g'  \
                -e 's/\/dev\///g'
        fi
    }


    # No operation was performed:
    # prints either a custom message (argument $1) or the default one, and sets output flag HDD_SUCCESS accordingly
    function hdd_no_operation() {
        if [ ! -z $1 ]; then
            echo $1
        else
            echo "     $(font fg_red)Operation stopped$(font reset) for unknown reasons."
        fi
        HDD_SUCCESS=1
    }


    # Gets all available SCSI/SATA drives (and others identified with prefix 'sd')
    function hdd_get_all() {
        echo $( ls -1 /dev | sed -n 's/sd.$/\0/p' )
    }


    # Returns all drives preceded with "/dev/"
    function hdd_get_drives() {
        if [ -z $1 ]; then
            local HDD_ARGS=$(hdd_get_all)
        else
            local HDD_ARGS="$@"
        fi

        HDD_ARGS=(${(s/ /)HDD_ARGS})            # Makes a string array from the string
        HDD_ARGS=(${HDD_ARGS[@]//\/dev\//})     # Removes any existing "/dev/" (avoids the duplicate "/dev//dev/")
        echo ${HDD_ARGS/#/\/dev\/}              # Adds "/dev/" to all drives
    }


    # Fetches disk exceptions for 'hdd' to ignore
    function hdd_get_exceptions() {
        hdd_add_ssd_as_exception
        local HDD_ELEMS=(${(s/ /)HDD_EXCEPTIONS})
        (IFS='|' ; HDD_TEMP=${HDD_ELEMS/#/\\\/dev\\\/} ; echo "${^HDD_TEMP}" | sed -e 's/|/\\|/g')
    }


    # Gets root permission to run ('hdparm' needs root access)
    function hdd_get_permissions() {
        if [[ $(sudo echo -n) ]]; then
            echo "     $(font fg_red)Invalid password.$(font reset) Cannot execute."
            return 1
        else
            echo "     Permission granted."
            return 0
        fi
    }


    # Executes the command for the given drives after processing available drives and exclusions
    function hdd_execute() {
        local HDD_HDPARM=()
        local HDD_EXEC_SUCCESS=()
        local HDD_EXEC_ERROR=()
        local HDD_EXECUTE=
        local HDD_EXEC_COMMAND=$1
        local HDD_EXEC_DRIVES=(${@:2})

        for drive in $HDD_EXEC_DRIVES; do
            if [[ $drive =~ "^/dev/sd." ]]; then
                HDD_HDPARM=$( sudo hdparm $HDD_EXEC_COMMAND $drive 2>&1 )
                HDD_SUCCESS=$?
            else
                HDD_HDPARM=( "$drive is not a valid drive." )
                HDD_SUCCESS=1
            fi

            if [ $HDD_SUCCESS -eq 0 ]; then
                HDD_EXEC_SUCCESS+=("$HDD_HDPARM\n")
            else
                HDD_EXEC_ERROR+=("$HDD_HDPARM\n")
            fi
        done

        # Resets the flag
        HDD_SUCCESS=0

        echo ""
        case $1 in
            # Command: standby
            ("-y")
                for output in $HDD_EXEC_SUCCESS; do
                    echo $output | sed -rz -e 's/\n(.*):\n(.*)\n/\      ……  \1:\2/g'
                done
                ;;

            # Command: status
            ("-C")
                local HDD_OUTPUT=()
                for output in $HDD_EXEC_SUCCESS; do
                    HDD_OUTPUT+=("$(
                        echo $output                                |
                        sed -rz                                     \
                            -e 's/ drive state is://g'              \
                            -e 's/\n\n/\n/g'                        \
                            -e 's/:\n/:/g'                          \
                            -e 's/\n([^:]*):\s*([^\n]*)/\1 \2\n/g'
                    )\n")
                done

                # Only here we need the partition labels
                hdd_get_partition_labels

                HDD_EXECUTE=$(
                    local HDD_HEADER=$( printf "%12sC%17s" '' '' | sed -re 's/\ /─/g' )
                    HDD_HEADER=$( printf "%5sL%sR" '' $HDD_HEADER )

                    echo $HDD_HEADER | sed -e 's/L/┌/g' -e 's/R/┐/g' -e 's/C/┬/g'
                    printf "%5s│ $(font bold)%10s$(font reset) │ $(font bold)%-15s$(font reset) │ $(font bold)%s$(font reset)\n" '' 'DRIVE' 'STATUS' 'PARTITIONS'
                    echo $HDD_HEADER | sed -e 's/L/├/g' -e 's/R/┤/g' -e 's/C/┼/g'
                    for line in $HDD_OUTPUT; do
                        e=(${(s/ /)line})
                        printf "%5s│ %10s │ §§§%15s │ $(font fg 241)%s$(font reset)\n" " " "${e[1]}" "${e[2][1,-3]}" "${HDD_PARTITIONS[${e[1]}][1,-3]}"
                    done
                    echo $HDD_HEADER | sed -e 's/L/└/g' -e 's/R/┘/g' -e 's/C/┴/g'
                )

                echo $HDD_EXECUTE                                                           |
                sed -r                                                                      \
                    -e "s/(\§{3})(\s*)(unknown)/$(font fg 238)\3\2$(font reset)/g"          \
                    -e "s/(\§{3})(\s*)(active\/idle)/$(font fg_green)\3\2$(font reset)/g"   \
                    -e "s/(\§{3})(\s*)(standby)/$(font fg_yellow)\3\2$(font reset)/g"       \
                    -e "s/(\§{3})(\s*)(sleep)/$(font fg_red)\3\2$(font reset)/g"
                ;;
        esac

        # Report errors safely caught
        if [[ ! -z $HDD_EXEC_ERROR ]]; then
            echo "\nThe following $(font fg_red)errors$(font reset) were safely caught:"
            for error in $HDD_EXEC_ERROR; do
                echo "    -> $error" | sed -rz -e "s/\n/ /g" -e "s/$/\n/"
            done
            HDD_CONTROLLED_ERROR=1
        fi

        return $HDD_SUCCESS
    }


    # Help printed when no arguments are provided or 'hdd help' is issued
    function hdd_help() {
        echo "   $(font bold fg_cyan)                   zshrc's HDD status management helper                   $(font reset)
   ──────────────────────────────────────────────────────────────────────────
   $(font bold underline)Usage$(font reset):  $(font bg 238) hdd OPERATION [-f | --force] [DRIVES…] $(font reset)

   $(font bold underline)Arguments$(font reset):
      $(font bg 238) OPERATION $(font reset) ───┬── $(font bg 238) check/status $(font reset)   $(font fg 249)Checks drives statuses in a table.$(font reset)
          │          └── $(font bg 238) standby $(font reset)        $(font fg 249)Sends standby signal to drives.$(font reset)
          └── May be optionally preceded by $(font bg 238)--$(font reset) (e.g. $(font bg 238)--status$(font reset)).
      $(font bg 238) [-f | --force] $(font reset)                    $(font fg 249)Force mode: ignore exceptions.$(font reset)
      $(font bg 238) [DRIVES…] $(font reset)                         $(font fg 249)Drives separated by space.$(font reset)
"
        echo "   $(font underline)Available drives$(font reset):   $(font fg 241)$(hdd_printf $(hdd_get_drives))$(font reset)"
        echo "   $(font underline)Exceptions$(font reset):         $(font fg 241)$(hdd_printf $HDD_EXCLUDE)$(font reset)"
        echo "      └── Solid state drives are automatically added as exceptions."
    }


    # --------------------
    #      MAIN BLOCK
    # --------------------

    local HDD_SUCCESS=0
    local HDD_CONTROLLED_ERROR=0
    local HDD_JUMP=0
    local HDD_OPER=
    local HDD_DRIVES=
    local HDD_EXCLUDE=$(hdd_get_exceptions)
    local HDD_ARG_POS=2

    # No args? Help!
    if [ -z $1 ]; then
        hdd_help
        HDD_JUMP=1
    fi

    # Args provided, translate to respective 'hdparm' argument.
    # If help is requested, we'll jump execution.
    if [ $HDD_JUMP -eq 0 ]; then
        case $1 in
            ("check" | "status" | "--check" | "--status")
                echo "     HDD status check requested."
                HDD_OPER='-C'
                ;;
            ("standby" | "--standby")
                echo "     HDD standby requested."
                HDD_OPER='-y'
                ;;
            ("help" | "--help")
                hdd_help
                HDD_JUMP=1
                ;;
            (*)
                hdd_no_operation "     $(font fg_red)Invalid arguments provided.$(font reset)"
                ;;
        esac
    fi

    # Args correctly parsed and no help requested: let's execute!
    if [ $HDD_SUCCESS -eq 0 ] && [ $HDD_JUMP -eq 0 ]; then

        if [[ $2 == "-f" || $2 == "--force" ]]; then
            HDD_EXCLUDE=""
            HDD_ARG_POS=3
        fi

        if [ -z ${@:$HDD_ARG_POS:1} ] || [[ ${@:$HDD_ARG_POS:1} == "all" ]]; then
            HDD_DRIVES=$(hdd_get_drives)
        else
            HDD_DRIVES=$(hdd_get_drives ${@:$HDD_ARG_POS})
        fi

        if [[ $HDD_EXCLUDE != "" ]]; then
            HDD_DRIVES=$(echo $HDD_DRIVES | sed -e "s/$HDD_EXCLUDE//g" )
        fi
        echo "     $(font bold underline)Exceptions$(font reset):        $(font fg 241)$(hdd_printf $HDD_EXCLUDE)$(font reset)"
        echo "     $(font bold underline)Selected drives$(font reset):   $(font fg 241)$(hdd_printf $HDD_DRIVES)$(font reset)"
        if [ -z $HDD_DRIVES ]; then
            echo "     $(font fg_green)Nothing to do.$(font bold)"
            HDD_JUMP=1
        fi

        if [ $HDD_JUMP -eq 0 ]; then
            local HDD_PERM_OUTPUT=$(hdd_get_permissions)
            if [ $? -ne 0 ]; then
                hdd_no_operation $HDD_PERM_OUTPUT
            else
                echo $HDD_PERM_OUTPUT
            fi

            if [ $HDD_SUCCESS -eq 0 ]; then
                hdd_execute $HDD_OPER ${(s/ /)HDD_DRIVES}
                local HDD_SUCCESS=$?
                if [ $HDD_SUCCESS -ne 0 ]; then
                    hdd_no_operation "\n     $(font fg_red)Operation failed.$(font reset)"
                else
                    if [ $HDD_CONTROLLED_ERROR -eq 0 ]; then
                        echo "\n     $(font fg_green)Operation reported success.$(font reset)"
                    else
                        hdd_no_operation "\n     $(font fg_yellow)Operation reported success, although with errors safely caught.$(font reset)"
                    fi
                fi
            fi
        fi

    fi

    unset -f hdd_add_ssd_as_exception
    unset -f hdd_get_partition_labels
    unset -f hdd_printf
    unset -f hdd_no_operation
    unset -f hdd_get_all
    unset -f hdd_get_drives
    unset -f hdd_get_exceptions
    unset -f hdd_get_permissions
    unset -f hdd_execute

    echo ""     # Just some more spacing for those looks
    return $HDD_SUCCESS
}
