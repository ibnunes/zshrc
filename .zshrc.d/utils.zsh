function yesno() {
    local answer=
    while [[ ! $answer =~ "y|Y|n|N" ]]; do
        echo -n "$@ (y/N) " > /dev/stdout
        read answer
    done
    [[ $answer =~ 'y|Y' ]] && return 0 || return 1      # [0]=Yes [1]=No
}
