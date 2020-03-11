# ------------------------------------------------------------------------------
# ZSH Configuration File
# 
# Replace <yourusername> with your Linux username where necessary.
# The use of oh-my-zsh is highly recommended.
# ------------------------------------------------------------------------------


# Append the following code to the original file .zshrc:

for cfg in "$HOME"/.zshrc.d/*.zsh; do
    . "$cfg"
done
unset -v cfg
