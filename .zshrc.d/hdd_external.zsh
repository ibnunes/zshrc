# These functions are considered external and must have some variables manually set.
# Such variables are marked with [TODO MANUALLY].

function hddreport() {
    # Checks if there are additional arguments.
    # In particular, checks for -h (human readable).
    local additionalarg=
    local humanreadable=0
    if [[ $1 == "-h" ]]; then
        additionalarg='-h'
        humanreadable=1
    fi

    # [TODO MANUALLY]
    # Root directory that the function will consider all directories are originated from.
    local ROOT_DIR="/mnt"

    # [TODO MANUALLY]
    # Manually declares associative array with locations to check.
    #   -> "dirX" will redirect to "/mnt/dirX";
    #   -> Sub-directories are separated by '|'.
    # This example will perform a report on the following directories:
    #   -> /mnt/dirA/dirA1
    #   -> /mnt/dirB/dirB1
    #   -> /mnt/dirB/dirB2/dirB2a
    #   -> /mnt/dirB/dirB3
    declare -A LOCATIONS
    LOCATIONS[dirA]="dirA1"
    LOCATIONS[dirB]="dirB1|dirB2/dirB2a|dirB3"
    # ...

    # This flag will control the output for the first row.
    local is_first=1

    # Output the report:
    for disk in ${(k)LOCATIONS}; do

        # 1. Header with disk
        if (( is_first )); then
            printf '┌'; printf '─%.0s' {1..55}; printf '┐\n'
            is_first=0
        else
            printf '├'; printf '─%.0s' {1..32}; printf '┴'; printf '─%.0s' {1..22}; printf '┤\n'
        fi
        printf "│$(font bold fg_green) %-53s $(font reset)│\n" "$disk"
        printf '├'; printf '─%.0s' {1..32}; printf '┬'; printf '─%.0s' {1..22}; printf '┤\n'

        # 2. Used space by each directory in disk
        for dir in "${(s:|:)LOCATIONS[$disk]}"; do

            # 2.1. Get used space by directory (location)
            local location="$ROOT_DIR/$disk/$dir"
            local space=$(sudo du -s $additionalarg $location 2> /dev/null | sed -re "s|([0-9\.]*)([KMGTE])?.*$|\1 \2B|g" )

            # 2.2. Cleans up output if it isn't "human readable" (removes final space and "B")
            if (( ! humanreadable )); then
                space=$(echo $space | sed -re "s|[[:space:]]B$||g")
            fi

            # 2.3. If there was an error, $space is empty, therefore report "N/A" in red; otherwise, report used space
            if [[ -z $space ]]; then
                printf "│ $(font italic fg 249)%30s$(font reset) │ $(font fg_red)%20s$(font reset) │\n" "$dir" "N/A"
            else
                printf "│ $(font italic fg 249)%30s$(font reset) │ %20s │\n" "$dir" "$space"
            fi
        done
    done

    # 3. Final line of table
    printf '└'; printf '─%.0s' {1..32}; printf '┴'; printf '─%.0s' {1..22}; printf '┘\n'

    declare -r LOCATIONS
}


function hddsync() {
    # [TODO MANUALLY]
    # Locations to sync in format "source|destination|exclusions"
    local LOCATIONS=(
        "dirA_src|dirA_dst|dirA_exc"
        "dirB_src|dirB_dst|dirB_exc"
        # ...
    )

    # Maximum length for each column
    local max_length=20

    # Number of locations to sync
    local dim_locations=${#LOCATIONS[@]}

    # Declares local variables to be used
    local source=
    local destination=
    local exclusions=
    local out_source=
    local out_destination=
    local out_exclusions=
    local sync_command=
    local report_sent=
    local report_received=
    local report_rate=
    local report_total=
    local report_speedup=

    # Sync command format to be used with printf
    local SYNC_COMMAND_FORMAT="sudo rsync -artEPv '%s/' '%s' --exclude '%s'"

    # Counter to control last line output
    local i=1

    # Table header
    printf '┌'; printf '─%.0s' {1..$((max_length+2))}; printf '┬'; printf '─%.0s' {1..$((max_length+2))}; printf '┬'; printf '─%.0s' {1..$((max_length+2))}; printf '┐\n'
    printf "│$(font bold) %-$((max_length))s $(font reset)│$(font bold) %-$((max_length))s $(font reset)│$(font bold) %-$((max_length))s $(font reset)│\n" "SOURCE" "DESTINATION" "EXCLUSIONS"
    printf '├'; printf '─%.0s' {1..$((max_length+2))}; printf '┼'; printf '─%.0s' {1..$((max_length+2))}; printf '┼'; printf '─%.0s' {1..$((max_length+2))}; printf '┤\n'

    # Process each location sync
    for location in $LOCATIONS; do

        # Split the string with IFS
        IFS="|" read -r source destination exclusions <<< $location

        # Fill the empty fields with an empty string and truncates for output
        source=${source:-""}
        destination=${destination:-""}
        exclusions=${exclusions:-""}

        if (( ${#source} > max_length )); then
            out_source="${source:0:$((max_length-1))}…"
        else
            out_source="$source"
        fi

        if (( ${#destination} > max_length )); then
            out_destination="${destination:0:$((max_length-1))}…"
        else
            out_destination="$destination"
        fi

        if (( ${#exclusions} > max_length )); then
            out_exclusions="${exclusions:0:$((max_length-1))}…"
        else
            out_exclusions="$exclusions"
        fi

        # Begins sub-row to provide syncing report
        printf "│ $(font italic)%-$((max_length))s$(font reset) │ $(font italic)%-$((max_length))s$(font reset) │ $(font italic fg 249)%-$((max_length))s$(font reset) │\n" $out_source $out_destination $out_exclusions
        printf '├'; printf '─%.0s' {1..$((max_length+2))}; printf '┴'; printf '─%.0s' {1..$((max_length+2))}; printf '┴'; printf '─%.0s' {1..$((max_length+2))}; printf '┤\n'

        # Executes the sync command and catches both output and return code
        printf "│     %-$(((max_length+2)*3-4))s │\n" "Syncing..."
        sync_command=$(printf "$SYNC_COMMAND_FORMAT" "$source" "$destination" "$exclusions")
        local HDD_SYNC_OUTPUT=$(eval "$sync_command")
        local HDD_SYNC_RESULT=$?

        # Outputs the report
        if [ $HDD_SYNC_RESULT -eq 0 ]; then
            printf "│         -> $(font bold fg_green)%-$(((max_length+2)*3-11))s$(font reset) │\n" "Success"

            local sync_result="$(
                echo $HDD_SYNC_OUTPUT | sed -n -E 's/.*sent ([0-9,]+).*received ([0-9,]+).* ([0-9,]+\.[0-9]+).*/\1 \2 \3 /p; s/.*total size is ([0-9,]+).*speedup is ([0-9,]+\.[0-9]+).*/\1 \2/p' | tr '\n' ' '
            )"
            read -r report_sent report_received report_rate report_total report_speedup <<< "$sync_result"

            printf "│            Sent:       $(font fg 249)%-$(((max_length+2)*3-33))s$(font italic)     bytes$(font reset) │\n" "$report_sent"
            printf "│            Received:   $(font fg 249)%-$(((max_length+2)*3-33))s$(font italic)     bytes$(font reset) │\n" "$report_received"
            printf "│            Rate:       $(font fg 249)%-$(((max_length+2)*3-33))s$(font italic) bytes/sec$(font reset) │\n" "$report_rate"
            printf "│            Total:      $(font fg 249)%-$(((max_length+2)*3-33))s$(font italic)     bytes$(font reset) │\n" "$report_total"
            printf "│            Speedup:    $(font fg 249)%-$(((max_length+2)*3-33))s$(font italic) bytes/sec$(font reset) │\n" "$report_speedup"
        else
            printf "│         -> $(font bold fg_red)%-$(((max_length+2)*3-11))s$(font reset) │\n" "Error"
            printf "│            $(font italic fg 249)%-$(((max_length+2)*3-11))s$(font reset) │\n" "Consult $SYNC_LOG_FILE for more information."
        fi

        # Conditional last table row
        if (( $i < $dim_locations )); then
            printf '├'; printf '─%.0s' {1..$((max_length+2))}; printf '┬'; printf '─%.0s' {1..$((max_length+2))}; printf '┬'; printf '─%.0s' {1..$((max_length+2))}; printf '┤\n'
        fi
        i=$(($i+1))
    done

    # Table footer
    printf "└"; printf '─%.0s' {1..$(((max_length+2)*3+2))}; printf "┘\n"
}
