function hdd() {
    echo ""     # Just some spacing for looks

    local HDD_EXCEPTIONS=""     # <-- Add exceptions separated by spaces. e.g. "sdb sdf sdh"

    function hdd_printf() {
        if [ -z $1 ]; then
            echo "None"
        else
            echo "$@"           |
            sed -e 's/|/ /g'    \
                -e 's/\\//g'
        fi
    }

    function hdd_no_operation() {
        if [ ! -z $1 ]; then
            echo $1
        else
            echo "     $(font fg_red)Operation stopped$(font reset) for unknown reasons."
        fi
        HDD_SUCCESS=1
    }

    function hdd_get_all() {
        echo $( ls -1 /dev | sed -n 's/sd.$/\0/p' )
    }

    function hdd_get_drives() {
        if [ -z $1 ]; then
            local HDD_ARGS=$(hdd_get_all)
        else
            local HDD_ARGS="$@"
        fi
        HDD_ARGS=(${(s/ /)HDD_ARGS})
        echo ${HDD_ARGS/#/\/dev\/}
    }

    function hdd_get_exceptions() {
        local HDD_ELEMS=(${(s/ /)HDD_EXCEPTIONS})
        (IFS='|' ; HDD_TEMP=${HDD_ELEMS/#/\\\/dev\\\/} ; echo "${^HDD_TEMP}" | sed -e 's/|/\\|/g')
    }

    function hdd_get_permissions() {
        if [[ $(sudo echo -n) ]]; then
            echo "     $(font fg_red)Invalid password.$(font reset) Cannot execute."
            return 1
        else
            echo "     Permission granted."
            return 0
        fi
    }

    function hdd_execute() {
        local HDD_HDPARM=$(sudo hdparm $1 ${@:2})
        HDD_SUCCESS=$?

        while read -r output; do
            case $1 in
                ("-y")
                    echo $output | sed -rz -e 's/(.*):\n/\      ……  \1:\  /g'
                    ;;
            esac
        done < <( sudo hdparm $1 ${@:2} )

        case $1 in
            ("-C")
                echo ""
                local HDD_OUTPUT=()
                while read -r value; do
                    HDD_OUTPUT+=($value)
                done <                                          \
                    <( echo $HDD_HDPARM                         |
                    sed -rz                                     \
                        -e 's/ drive state is://g'              \
                        -e 's/\n\n/\n/g'                        \
                        -e 's/:\n/:/g'                          \
                        -e 's/\n([^:]*):\s*([^\n]*)/\1 \2\n/g'
                    )

                HDD_EXECUTE=$(
                    local HDD_HEADER=$( printf "%12sC%17s" '' '' | sed -re 's/\ /─/g' )
                    HDD_HEADER=$( printf "%5sL%sR" '' $HDD_HEADER )

                    echo $HDD_HEADER | sed -e 's/L/┌/g' -e 's/R/┐/g' -e 's/C/┬/g'
                    printf "%5s│ $(font bold)%10s$(font reset) │ $(font bold)%-15s$(font reset) │\n" '' 'DRIVE' 'STATUS'
                    echo $HDD_HEADER | sed -e 's/L/├/g' -e 's/R/┤/g' -e 's/C/┼/g'
                    for line in $HDD_OUTPUT; do
                        e=(${(s/ /)line})
                        printf "%5s│ %10s │ §§§%15s │\n" " " "${e[1]}" "${e[2]}"
                    done
                    echo $HDD_HEADER | sed -e 's/L/└/g' -e 's/R/┘/g' -e 's/C/┴/g'
                )

                echo $HDD_EXECUTE                               |
                sed -r                                          \
                    -e "s/(\§{3})(\s*)(unknown)/$(font fg 238)\3\2$(font reset)/g"      \
                    -e "s/(\§{3})(\s*)(active\/idle)/$(font fg_green)\3\2$(font reset)/g" \
                    -e "s/(\§{3})(\s*)(standby)/$(font fg_yellow)\3\2$(font reset)/g"      \
                    -e "s/(\§{3})(\s*)(sleep)/$(font fg_red)\3\2$(font reset)/g"
                ;;
        esac

        return $HDD_SUCCESS
    }

    function hdd_help() {
        echo "   $(font bold fg_cyan)                   zshrc's HDD status management helper                   $(font reset)
   ──────────────────────────────────────────────────────────────────────────
   $(font bold underline)Usage$(font reset):  $(font bg 238) hdd OPERATION [-f | --force] [DRIVES…] $(font reset)

   $(font bold underline)Arguments$(font reset):
      $(font bg 238) OPERATION $(font reset) ───┬── check/status     $(font fg 249)Checks drives statuses in a table.$(font reset)
                     └── standby          $(font fg 249)Sends standby signal to drives.$(font reset)
      $(font bg 238) [-f | --force] $(font reset)                    $(font fg 249)Force mode: ignore exceptions.$(font reset)
      $(font bg 238) [DRIVES…] $(font reset)                         $(font fg 249)Drives separated by space$(font reset)
"
        echo "   $(font underline)Available drives$(font reset):   $(font fg 241)$(hdd_printf $(hdd_get_drives))$(font reset)"
        echo "   $(font underline)Exceptions$(font reset):         $(font fg 241)$(hdd_printf $HDD_EXCLUDE)$(font reset)"
    }


    local HDD_SUCCESS=0
    local HDD_JUMP=0
    local HDD_OPER=
    local HDD_DRIVES=
    local HDD_EXCLUDE=$(hdd_get_exceptions)
    local HDD_ARG_POS=2

    if [ -z $1 ]; then
        hdd_help
        HDD_JUMP=1
    fi

    if [ $HDD_JUMP -eq 0 ]; then
        case $1 in
            ("check" | "status")
                echo "     HDD status check requested."
                HDD_OPER='-C'
                ;;
            ("standby")
                echo "     HDD standby requested."
                HDD_OPER='-y'
                ;;
            (*)
                hdd_no_operation "     $(font fg_red)Invalid arguments provided.$(font reset)"
                ;;
        esac
    fi

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
                    echo "\n     $(font fg_green)Operation reported success.$(font reset)"
                fi
            fi
        fi

    fi

    unset -f hdd_printf
    unset -f hdd_no_operation
    unset -f hdd_get_all
    unset -f hdd_get_drives
    unset -f hdd_get_exceptions
    unset -f hdd_get_permissions
    unset -f hdd_execute
    unset -f hdd_help

    echo ""     # Just some more spacing for those looks
    return $HDD_SUCCESS
}