#!/bin/zsh
eval "clear"

echo "ZSH Custom Configurations"
echo ""
read -p "Do you want to clear your ser zsh configuration file (.zshrc) file? (y/n)" clearZshrc

if [ $clearZshrc = "y" ] || [ $clearZshrc = "Y" ]; then
    echo "Clearing user zsh configuration file"
    rm -f "$HOME"/.zshrc
    echo "Installing new zsh configuration file"
    eval "curl -s https://raw.githubusercontent.com/thoga31/zshrc/master/.zshrc -o "$HOME"/.zshrc"
else
    echo "Updating zsh configuration file"
    eval "echo \"\n\" >> ~/.zshrc"
    eval "curl -s https://raw.githubusercontent.com/thoga31/zshrc/master/.zshrc >> "$HOME"/.zshrc"
fi

echo "Creating ZSH individual configuration folder"
if [ ! -d "$HOME"/.zshrc.d ]; then
	mkdir -p "$HOME"/.zshrc.d;
fi

echo "Installing zshrc script"
eval "curl -s https://raw.githubusercontent.com/thoga31/zshrc/master/.zshrc.d/zsh.zsh -o "$HOME"/.zshrc.d/zsh.zsh"

echo "Installing zsh individual files"
eval "curl -s https://raw.githubusercontent.com/thoga31/zshrc/master/.zshrc.d/alias.zsh -o "$HOME"/.zshrc.d/alias.zsh"

read -p "Install C compilation with gcc? (y/n) " customCCompilationScript
if [ $customCCompilationScript = "y" ] && [ $customCCompilationScript = "Y" ]; then
    eval "curl -s https://raw.githubusercontent.com/thoga31/zshrc/master/.zshrc.d/cc.zsh -o "$HOME"/.zshrc.d/cc.zsh"
fi

read -p "Install OpenGL compilation with g++? (y/n) " openGlCompilation
if [ $openGlCompilation = "y" ] && [ $openGlCompilation = "Y" ]; then
    eval "curl -s https://github.com/thoga31/zshrc/blob/master/.zshrc.d/gl.zsh -o "$HOME"/.zshrc.d/gl.zsh"
fi

echo -p "Install Package manager aliases? (y/n) " pkgManagerAliases
if [ $pkgManagerAliases = "y" ] && [ $pkgManagerAliases = "Y" ]; then
    eval "curl -s https://raw.githubusercontent.com/thoga31/zshrc/master/.zshrc.d/up.zsh -o "$HOME"/.zshrc.d/up.zsh"
fi

echo "Multi alias script"
echo "The multi alias script will allow to type \"ubi tc\" and the terminal changes to the tc folder that belongs to the ubi collection"
read -p "Create multi alias script? (y/n) " customMultiAliasScript
if [ $customMultiAliasScript = "y" ] && [ $customMultiAliasScript = "Y" ]; then
    endFlag="y"
    varStr='$1'
    while [ $endFlag = "y" ]
    do
        read -p "Enter the multi alias name: " multiAliasName
        echo "# ----------------------------------------\n# $multiAliasName navigation shortcuts\n# ----------------------------------------" > $HOME/.zshrc.d/$multiAliasName.zsh
        echo "\nfunction $multiAliasName {\n\tcase \$1" >> $HOME/.zshrc.d/$multiAliasName.zsh
        exitFlag="n"
        while [ $exitFlag = "n" ]
        do
            read -p "Alias: " aliasName
            read -p "Path: " aliasPath
            echo "\t\t\"$aliasName\") eval \"cd $aliasPath\"" >> $HOME/.zshrc.d/$multiAliasName.zsh
            echo "\t\t;;" >> $HOME/.zshrc.d/$multiAliasName.zsh
            read -p "End multi alias script creation? (y/n) " exitFlag
        done
        echo "\tesac\n}" >> $HOME/.zshrc.d/$multiAliasName.zsh
        read -p "Create new multi alias script? (y/n) " endFlag
    done
fi

echo "Reloading zsh configuration file"
eval "source "$HOME"/.zshrc"
echo ""
echo "All the zsh configuration files were installed and loaded successfully"
