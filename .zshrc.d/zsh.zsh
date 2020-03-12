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
        "-l")
            	for cfg in ~/.zshrc.d/*.zsh; do
                	echo ${$(basename -- "$cfg")%.*}
            	done
        	;;
	"-h")
            	echo "+------------+"
            	echo "| zshrc help |"
            	echo "+------------+"
            	echo "usage: zshrc option [parameters]"
            	echo "Option\t\tDescription"
            	echo "-l\t\tLists all the loaded configurations"
           	echo "-c\t\tOpens the configuration file\n\t\tIf no configuration name is passed the default \"~./zshrc\" will be opened"
            	echo "-r\t\tReloads the zsh configurations"
            	echo "-cr\t\tIt's the usage of -c and -r"
            	echo "-a\t\tAdds a new alias to the alias configuration file\n\t\tIt requires two parameters <alias_name> and <command>"
            	echo "--create-config\tCreates a new confign file"
            	echo "-h\t\tShows the help menu"
		;;
        *)
		eval "zshrc -h"
		;;
	esac
}
