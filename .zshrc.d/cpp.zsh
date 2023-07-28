# ----------------------------------------
# C++ compilation with g++
# ----------------------------------------

g++() {
    # Enable convenience options for g++
    set -- -Wall -Wextra "$@"
    set -- -fno-diagnostics-show-caret "$@"
    command g++ "$@"
}

__std-gpp() {
    local std=$1
    shift
    set -- -pedantic-errors -std=$std "$@"
    set -- -Werror=main "$@"
    set -- -Werror=strict-prototypes "$@"
    set -- -Werror=missing-prototypes "$@"
    set -- -Werror=missing-declarations "$@"
    set -- -Werror=implicit-int -Werror=implicit-function-declaration "$@"
    set -- -Wformat-security "$@"
    g++ "$@"
}

cpp20() {
    __std-gpp 'c++20' "$@"
}

cpp17() {
    __std-gpp 'c++17' "$@"
}

cpp11() {
    __std-gpp 'c++11' "$@"
}

cpp98() {
    __std-gpp 'c++98' "$@"
}

runcpp() {
    cpp20 "$@"
}
