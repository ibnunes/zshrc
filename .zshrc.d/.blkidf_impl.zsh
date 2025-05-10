#!/bin/bash

# NOTE:
#   Using .zsh extension for the automated setup script (it assumes all files are .zsh)
#   Otherwise this is Bash code, not zsh.

function blkidf_impl() {
    function print_table() {
        for h in "${headers[@]}"; do
            printf "%-${widths[$h]}s  " "$h"
        done
        echo
        for dev in "${devices[@]}"; do
            for h in "${headers[@]}"; do
                printf "%-${widths[$h]}s  " "${data[$dev,$h]}"
            done
            echo
        done
    }

    function print_csv() {
        (IFS=','; echo "${headers[*]}")
        for dev in "${devices[@]}"; do
            row=()
            for h in "${headers[@]}"; do
                val="${data[$dev,$h]}"
                # Escape quotes and wrap if necessary
                val="${val//\"/\"\"}"
                [[ "$val" == *[,\"]* ]] && val="\"$val\""
                row+=("$val")
            done
            (IFS=','; echo "${row[*]}")
        done
    }

    function print_markdown() {
        printf "|"
        for h in "${headers[@]}"; do
            printf " %-*s |" "${widths[$h]}" "$h"
        done
        echo
        printf "|"
        for h in "${headers[@]}"; do
            printf " %s |" "$(printf '%*s' "${widths[$h]}" | tr ' ' '-')"
        done
        echo
        for dev in "${devices[@]}"; do
            printf "|"
            for h in "${headers[@]}"; do
                printf " %-*s |" "${widths[$h]}" "${data[$dev,$h]}"
            done
            echo
        done
    }

    function print_json() {
        echo "["
        for i in "${!devices[@]}"; do
            dev="${devices[$i]}"
            echo "  {"
            for j in "${!headers[@]}"; do
                h="${headers[$j]}"
                val="${data[$dev,$h]}"
                val="${val//\"/\\\"}"
                comma=$([[ $j -lt $((${#headers[@]} - 1)) ]] && echo "," || echo "")
                echo "    \"${h}\": \"${val}\"${comma}"
            done
            comma=$([[ $i -lt $((${#devices[@]} - 1)) ]] && echo "," || echo "")
            echo "  }$comma"
        done
        echo "]"
    }

    function print_toml() {
        for dev in "${devices[@]}"; do
            # Remove /dev/ and replace any remaining slashes to avoid TOML table issues
            safe_dev=$(echo "${dev#/dev/}" | tr '/' '_')
            echo "[device.\"$safe_dev\"]"
            for h in "${headers[@]}"; do
                val="${data[$dev,$h]}"
                val="${val//\"/\\\"}"
                echo "$h = \"$val\""
            done
            echo
        done
    }

    function print_yaml() {
        echo "devices:"
        for dev in "${devices[@]}"; do
            echo "  - DEVICE: \"$dev\""
            for h in "${headers[@]}"; do
                [[ "$h" == "DEVICE" ]] && continue
                val="${data[$dev,$h]}"
                val="${val//\"/\\\"}"
                echo "    $h: \"$val\""
            done
        done
    }

    function print_ini() {
        for dev in "${devices[@]}"; do
            safe_dev=$(echo "${dev#/dev/}" | tr '/' '_')
            echo "[$safe_dev]"
            for h in "${headers[@]}"; do
                val="${data[$dev,$h]}"
                val="${val//\"/\\\"}"
                echo "$h=$val"
            done
            echo
        done
    }

    function print_html() {
        echo "<table border=\"1\">"
        echo "  <tr>"
        for h in "${headers[@]}"; do
            echo "    <th>$h</th>"
        done
        echo "  </tr>"
        for dev in "${devices[@]}"; do
            echo "  <tr>"
            for h in "${headers[@]}"; do
                val="${data[$dev,$h]}"
                echo "    <td>${val}</td>"
            done
            echo "  </tr>"
        done
        echo "</table>"
    }

    function print_sql() {
        table="blkid_data"
        cols=$(IFS=','; echo "${headers[*]}")
        for dev in "${devices[@]}"; do
            values=()
            for h in "${headers[@]}"; do
                val="${data[$dev,$h]}"
                val="${val//\'/\'\'}"   # Escape single quotes
                values+=("'$val'")
            done
            echo "INSERT INTO $table ($cols) VALUES (${values[*]});"
        done
    }

    function print_ndjson() {
        for dev in "${devices[@]}"; do
            echo -n "{"
            for i in "${!headers[@]}"; do
                h="${headers[$i]}"
                val="${data[$dev,$h]//\"/\\\"}"
                echo -n "\"$h\":\"$val\""
                [[ $i -lt $(( ${#headers[@]} - 1 )) ]] && echo -n ","
            done
            echo "}"
        done
    }

    function print_xml() {
        echo "<devices>"
        for dev in "${devices[@]}"; do
            echo "  <device>"
            for h in "${headers[@]}"; do
                val="${data[$dev,$h]}"
                val="${val//&/&amp;}"
                val="${val//</&lt;}"
                val="${val//>/&gt;}"
                val="${val//\"/&quot;}"
                val="${val//\'/&apos;}"
                echo "    <$h>$val</$h>"
            done
            echo "  </device>"
        done
        echo "</devices>"
    }

    # We assume we have this argument; this function should never be called directly anyway
    local format=$1

    # Get blkid output and check if it's empty.
    local blkid_output=$(blkid)
    if [[ -z "$blkid_output" ]]; then
        echo "No devices found by blkid."
        return 0
    fi

    # If not empty, let's try and format its output
    declare -A fields
    declare -A data
    declare -A widths
    declare -a devices

    # Parse blkid output
    while IFS= read -r line; do
        dev="${line%%:*}"
        devices+=("$dev")
        data["$dev,DEVICE"]="$dev"
        (( ${#dev} > ${widths["DEVICE"]:-0} )) && widths["DEVICE"]=${#dev}

        while [[ $line =~ ([A-Z0-9_]+)=\"([^\"]*)\" ]]; do
            key="${BASH_REMATCH[1]}"
            val="${BASH_REMATCH[2]}"
            fields["$key"]=1
            data["$dev,$key"]="$val"
            (( ${#key} > ${widths[$key]:-0} )) && widths["$key"]=${#key}
            (( ${#val} > ${widths[$key]} )) && widths["$key"]=${#val}
            line="${line#*\"}"
            line="${line#* }"
        done
    done <<< "$blkid_output"

    headers=("DEVICE")
    sorted_keys=($(printf "%s\n" "${!fields[@]}" | sort))
    headers+=("${sorted_keys[@]}")

    # Output based on format
    case "$format" in
        table)    print_table    ;;
        csv)      print_csv      ;;
        markdown) print_markdown ;;
        json)     print_json     ;;
        toml)     print_toml     ;;
        yaml)     print_yaml     ;;
        ini)      print_ini      ;;
        html)     print_html     ;;
        sql)      print_sql      ;;
        ndjson)   print_ndjson   ;;
        xml)      print_xml      ;;
        *)  # This case should be controlled by the calling main function
            ;;
    esac

    unset -f print_table
    unset -f print_csv
    unset -f print_markdown
    unset -f print_json
    unset -f print_toml
    unset -f print_yaml
    unset -f print_ini
    unset -f print_html
    unset -f print_sql
    unset -f print_ndjson
    unset -f print_xml
}
