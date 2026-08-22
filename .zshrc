export FZF_DEFAULT_OPTS='--layout=reverse --border'
alias s='ssh $(grep "^Host " ~/.ssh/config | awk "{print \$2}" | fzf)'
