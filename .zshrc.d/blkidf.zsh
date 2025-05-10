function blkidf() {
    function print_help() {
    cat <<EOF
Usage: $1 [--format=FORMAT]

Formats the output of the 'blkid' command as a table or structured data format.

Options:
  --format=FORMAT   Output format. Supported values:

    table       Aligned plain-text table (default)
    csv         Comma-separated values
    markdown    Markdown table
    json        JSON array of objects
    ndjson      Newline-delimited JSON
    yaml        YAML format
    toml        TOML format
    ini         INI format
    sql         SQL INSERT statements
    html        HTML table
    xml         XML document

  --help           Show this help message and exit

Examples:
  $1 --format table
  $1 --format json
EOF
    }

    # Inject default argument if none provided
    if [[ $# -eq 0 ]]; then
        set -- --format=table
    fi

    # Directly asking for help (just ignore any other arguments)
    if [[ "$1" == "--help" || "$1" == "-h" ]]; then
        print_help $(basename "$0")
        return 0
    fi

    BLKIDF_RESULT=0
    format="table"      # Default output format
    supported_formats=("table" "csv" "markdown" "json" "ndjson" "yaml" "toml" "ini" "sql" "html" "xml")

    # Parse command-line args
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --format=*)
                local format="${1#*=}"
                local script_path="${HOME}/.zshrc.d/.blkidf_impl.zsh"
                if [[ " ${supported_formats[@]} " =~ " $format " ]]; then
                    # blkid_impl was done for Bash!
                    if [[ -n "$BASH_VERSION" ]]; then
                        source "$script_path"
                        blkidf_impl "$format"
                        unset -f blkidf_impl
                    else
                        bash -c "source '$script_path'; blkidf_impl '$format'"
                    fi
                else
                    echo "Unknown format: $1"
                    BLKIDF_RESULT=1
                fi
                ;;
            *)
                echo "Unknown option: $1"
                BLKIDF_RESULT=1
                ;;
        esac
        shift
    done

    unset -f print_help

    return $BLKIDF_RESULT
}
