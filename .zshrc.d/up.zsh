# ----------------------------------------
# Package manager
# ----------------------------------------

pkgmgr() {
    if [ -z "$1" ]; then
        pkg="apt"
    else
        pkg=$1
    fi

    alias update="sudo $pkg update"
    alias upgrade="sudo $pkg upgrade"
    alias upall="update && upgrade"
    alias install="sudo $pkg install"
    alias remove="sudo $pkg remove"
    alias autoremove="sudo $pkg autoremove"

    unset -v pkg
}

# Execute the pkgmgr command
pkgmgr
