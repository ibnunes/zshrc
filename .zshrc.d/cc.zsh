# ----------------------------------------
# C compilation with gcc
# ----------------------------------------

alias indent='indent -npsl -bl'

gcc() {
    # Enable convenience options for gcc
    set -- -Wall -Wextra "$@"
    set -- -fno-diagnostics-show-caret "$@"
    command gcc "$@"
}

__std-gcc() {
    local std=$1
    shift
    set -- -pedantic-errors -std=$std "$@"
    set -- -Werror=main "$@"
    set -- -Werror=strict-prototypes "$@"
    set -- -Werror=missing-prototypes "$@"
    set -- -Werror=missing-declarations "$@"
    set -- -Werror=implicit-int -Werror=implicit-function-declaration "$@"
    set -- -Wformat-security "$@"
    gcc "$@"
}

c2x() {
    __std-gcc 'c2x' "$@"
}

c17() {
    __std-gcc 'c17' "$@"
}

c11() {
    __std-gcc 'c11' "$@"
}

c99() {
    __std-gcc 'c99' "$@"
}

c89() {
    __std-gcc 'c89' "$@"
}

runcc() {
    c17 "$@"
}
