ali="$HOME/.zshcustom/alias.zsh"
alias config='/usr/bin/git --git-dir=/home/violeine/.cfg/ --work-tree=/home/violeine'
alias xconf='$EDITOR ~/.Xresources'
alias zshconf='$EDITOR ~/.zshrc'
alias aliconf='$EDITOR $ali'
alias zshprof='$EDITOR ~/.zprofile'
alias xconf='$EDITOR ~/.Xresources'
alias zshconf='$EDITOR ~/.zshrc'
alias tconf='$EDITOR ~/.tmux.conf'
alias zshprof='$EDITOR ~/.zprofile'
alias hkconf='$EDITOR ~/.config/sxhkd/sxhkdrc'
alias bspconf='$EDITOR ~/.config/bspwm/bspwmrc'
alias pacin='pacman -Slq | fzf -m --preview '\''pacman -Si {1}'\'' | xargs -ro sudo pacman -S'
alias vim=nvim
alias vi=/usr/bin/vim
alias viconf='nvim ~/.config/vim/.vim/vimrc'
