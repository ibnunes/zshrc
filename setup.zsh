#!/bin/zsh

echo "ZSHRC Setup                                                     1.1.0-beta"
echo "──────────────────────────────────────────────────────────────────────────"
echo "   Loading components…"

function yesno() {
    local answer=
    while [[ ! $answer =~ "y|Y|n|N" ]]; do
        echo -n "$@ (y/N) " > /dev/stdout
        read answer
    done
    [[ $answer =~ 'y|Y' ]] && return 0 || return 1      # 0 for Yes, 1 for No
}

ZSHRC_FILES_ESSENTIAL=(
    "alias"
    "hdd"
    "mobaxterm"
    "utils"
    "zsh"
)

ZSHRC_FILES_DEV=(
    "cc"
    "cpp"
    "gl"
)

ZSH_CONFIG_FILE=".zshrc"
ZSH_CONFIG_PWD="$HOME/$ZSH_CONFIG_FILE"

ZSHRC_FOLDER=".zshrc.d"
ZSHRC_LOCAL_FOLDER="$HOME/$ZSHRC_FOLDER"

ZSHRC_REPO="https://raw.githubusercontent.com/ibnunes/zshrc/master/"


echo "   Creating .zshrc.d folder in home directory…"
if [ ! -d $ZSHRC_LOCAL_FOLDER ]; then
    mkdir -p $ZSHRC_LOCAL_FOLDER
fi

echo "   Appending ZSHRC loading code to user's .zshrc…"
curl -s "$ZSHRC_REPO/$ZSH_CONFIG_FILE" -a $ZSH_CONFIG_PWD

echo "   Installing essential ZSHRC configuration files…"
for f in $ZSHRC_FILES_ESSENTIAL; do
    echo "      $f.zsh"
    curl -s "$ZSHRC_REPO/$ZSHRC_FOLDER/$f.zsh" -o "$ZSHRC_LOCAL_FOLDER/$f.zsh"
done

yesno "-> Install developer configuration files? "
if [ $? -eq 0 ]; then
    echo "   Installing developer ZSHRC configuration files…"
    for f in $ZSHRC_FILES_DEV; do
        echo "      $f.zsh"
        curl -s "$ZSHRC_REPO/$ZSHRC_FOLDER/$f.zsh" -o "$ZSHRC_LOCAL_FOLDER/$f.zsh"
    done
fi

echo "   Reloading zsh configuration…"
source $ZSH_CONFIG_PWD

echo "   Cleaning up…"
unset -v ZSHRC_FILES_ESSENTIAL
unset -v ZSHRC_FILES_DEV
unset -v ZSH_CONFIG_FILE
unset -v ZSH_CONFIG_PWD
unset -v ZSHRC_FOLDER
unset -v ZSHRC_LOCAL_FOLDER
unset -f yesno

echo "   Installation complete!"
echo "──────────────────────────────────────────────────────────────────────────"
