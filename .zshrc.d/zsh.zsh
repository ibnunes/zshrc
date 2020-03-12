# ---------------------------------------
# ZSH Configuration
# ---------------------------------------

function zshrc {
	case $1 in
		"-c")
            if [ $# -eq 2 ]; then 
			    eval "nano ~/.zshrc.d/$2.zsh"
            else
                eval "nano ~/.zshrc"
            fi
            ;;
        "-r")
			eval "source ~/.zshrc"
            echo "zshrc updated"
			;;
        "-cr")
            eval "zshrc -c $2"
            eval "zshrc -r"
            ;;
		"-a")
			if [ $# -eq 3 ]; then
				eval 'echo "# Added at $(date)\nalias $2=\"$3\"" >> ~/.zshrc.d/alias.zsh'
				eval "zshrc -r"
			else
				echo "This option requires two parameters run \"zshrc -h\"for help"
			fi
			;;
        "--create-config")
            if [ $# -eq 2 ]; then
                eval "nano ~/.zshrc.d/$2.zsh"
            else
                echo "This option requires one parameter run \"zshrc -h\"for help"
            fi
            ;;
        "--multi-alias")
            read  "?Enter the multi alias name: " multiAliasName
            echo "# ----------------------------------------\n# $multiAliasName navigation shortcuts\n# ----------------------------------------" > $HOME/.zshrc.d/$multiAliasName.zsh
            echo "\nfunction $multiAliasName {\n\tcase \$1 in" >> $HOME/.zshrc.d/$multiAliasName.zsh
            exitFlag="n"
            while [ $exitFlag = "n" ]
            do
                read "?Alias: " aliasName
                read "?Path: " aliasPath
                echo "\t\t\"$aliasName\") eval \"cd $aliasPath\"" >> $HOME/.zshrc.d/$multiAliasName.zsh
                echo "\t\t;;" >> $HOME/.zshrc.d/$multiAliasName.zsh
                read "?End multi alias script creation? (y/n) " exitFlag
            done            
            echo "\tesac\n}" >> $HOME/.zshrc.d/$multiAliasName.zsh
            eval "zshrc -r"
            ;;
        "-l")
            for cfg in ~/.zshrc.d/*.zsh; do
                echo ${$(basename -- "$cfg")%.*}
            done
            ;;
        "-u")
            echo "Updating zsh script..."
            rm -f "$HOME"/.zshrc.d/zsh.zsh
            eval "curl -s https://raw.githubusercontent.com/thoga31/zshrc/master/.zshrc.d/zsh.zsh -o "$HOME"/.zshrc.d/zsh.zsh"
            eval "zshrc -r"
            echo "zsh script updated"
            ;;
	"-h")
            echo "+------------+"
            echo "| zshrc help |"
            echo "+------------+"
            echo "usage: zshrc option [parameters]\n"
            echo "Option\t\tDescription"
            echo "-l\t\tLists all the loaded configurations"
            echo "-c\t\tOpens the configuration file\n\t\tIf no configuration name is passed the default \"~./zshrc\" will be opened"
            echo "-r\t\tReloads the zsh configurations"
            echo "-cr\t\tIt's the usage of -c and -r"
            echo "-a\t\tAdds a new alias to the alias configuration file\n\t\tIt requires two parameters <alias_name> and <command>"
            echo "--create-config\tCreates a new confign file"
            echo "--multi-alias\tCreates a new multi alias script"
	        echo "-u\t\tUpdates this script"
            echo "-h\t\tShows the help menu"
            ;;
        *)
			eval "zshrc -h"
			;;
	esac
}
