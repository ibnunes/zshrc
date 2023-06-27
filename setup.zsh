#!/bin/zsh

function yesno() {
    local answer=
    while [[ ! $answer =~ "y|Y|n|N" ]]; do
        echo -n "$@ (y/N) " > /dev/stdout
        read answer
    done
    [[ $answer =~ 'y|Y' ]] && return 0 || return 1      # 0 for Yes, 1 for No
}

clear
echo "ZSH Custom Configurations\n"

yesno "Do you want to clear your zsh configuration file (.zshrc) file? "
if [ $? -eq 0 ]; then
    echo "Clearing user zsh configuration file"
    rm -f "$HOME"/.zshrc
fi

echo "Installing new zsh configuration file"
curl -s https://raw.githubusercontent.com/ibnunes/zshrc/master/.zshrc -a $HOME/.zshrc

echo "Creating ZSH individual configuration folder"
if [ ! -d "$HOME/.zshrc.d" ]; then
    mkdir -p $HOME/.zshrc.d;
fi

echo "Installing zshrc script"
curl -s https://raw.githubusercontent.com/ibnunes/zshrc/master/.zshrc.d/zsh.zsh -o $HOME/.zshrc.d/zsh.zsh

echo "Installing zsh individual files"
curl -s https://raw.githubusercontent.com/ibnunes/zshrc/master/.zshrc.d/alias.zsh -o $HOME/.zshrc.d/alias.zsh

yesno "Install C compilation with gcc? "
if [ $? -eq 0 ]; then
    curl -s https://raw.githubusercontent.com/ibnunes/zshrc/master/.zshrc.d/cc.zsh -o $HOME/.zshrc.d/cc.zsh
fi

yesno "Install OpenGL compilation with g++? "
if [ $? -eq 0 ]; then
    eval "curl -s https://raw.githubusercontent.com/ibnunes/zshrc/master/.zshrc.d/gl.zsh -o $HOME/.zshrc.d/gl.zsh"
fi


yesno "Install Package manager aliases? "
if [ $? -eq 0 ]; then
    eval "curl -s https://raw.githubusercontent.com/ibnunes/zshrc/master/.zshrc.d/up.zsh -o $HOME/.zshrc.d/up.zsh"
fi

echo "Multi alias script"
echo "The multi alias script will allow to type \"ubi tc\" and the terminal changes to the tc folder that belongs to the ubi collection"
yesno "Create multi alias script? "
if [ $? -eq 0 ]; then
    local endFlag=0
    local varStr='$1'
    while [ $endFlag -eq 0 ]; do
        read "?Enter the multi alias name: " multiAliasName
        echo "# ----------------------------------------\n# $multiAliasName navigation shortcuts\n# ----------------------------------------" > $HOME/.zshrc.d/$multiAliasName.zsh
        echo "\nfunction $multiAliasName {\n\tcase \$1 in" >> $HOME/.zshrc.d/$multiAliasName.zsh
        local exitFlag=1
        while [ $exitFlag -ne 0 ]; do
            local aliasName=""
            local aliasPath=""
            echo -n "Alias: "
            read aliasName
            echo -n "Path: "
            read aliasPath
            echo "\t\t\"$aliasName\") eval \"cd $aliasPath\"" >> $HOME/.zshrc.d/$multiAliasName.zsh
            echo "\t\t;;" >> $HOME/.zshrc.d/$multiAliasName.zsh
            yesno "End multi alias script creation? (y/N) "
            exitFlag=$?
        done
        echo "\tesac\n}" >> $HOME/.zshrc.d/$multiAliasName.zsh
        yesno "Create new multi alias script? "
        endFlag=$?
    done
fi

echo "Reloading zsh configuration file"
source $HOME/.zshrc
echo "\nAll the zsh configuration files were installed and loaded successfully"

unset -f yesno
