export PATH=$PATH:$HOME/.script:$HOME/.node_modules/bin
export npm_config_prefix=~/.node_modules
export EDITOR=nvim
export FZF_DEFAULT_COMMAND='rg --files --hidden'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_C_COMMAND='rg --hidden --files --sort-files --null 2> /dev/null | xargs -0 dirname | uniq'

