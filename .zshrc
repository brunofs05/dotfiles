# Autocomplete
autoload -Uz compinit
compinit
_comp_options+=(globdots)
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'

unsetopt BEEP

# Função para exibir a branch Git (somente se dentro de repo Git)
function git_branch {
  if command git rev-parse --is-inside-work-tree &>/dev/null; then
    local branch=$(git symbolic-ref --short HEAD 2>/dev/null || git rev-parse --short HEAD 2>/dev/null)
    echo "%F{magenta}[$branch] %f" # [main] (com espaço depois)
  else
    echo "" # nada se não for repositório git
  fi
}

# Detecta o virtualenv do Python
function python_venv {
  # Verifica se a variável de ambiente $VIRTUAL_ENV está definida
  if [[ -n "$VIRTUAL_ENV" ]]; then
    # ${VIRTUAL_ENV:t} pega apenas o "tail" (nome base) do caminho
    # Ex: /home/bruno/projetos/meu_app/venv -> venv
    echo "%F{green}(${VIRTUAL_ENV:t})%f " # (venv) (com espaço depois)
  else
    echo "" # nada se não houver venv ativo
  fi
}

# Define o prompt
function precmd {
  PROMPT_COLOR="%F{cyan}"
  # Adicionamos $(python_venv) no início do PROMPT
  # As funções git_branch e python_venv já incluem um espaço no final
  PROMPT=" $(python_venv)${PROMPT_COLOR}%F{#006BA6}%1~ $(git_branch)%F{cyan}▶%f "
}



export LANG=pt_BR.cp1252
export PATH=$PATH:/opt/android-sdk/platform-tools
export EDITOR=helix
export XDG_CURRENT_DESKTOP="gnome"

# Shortcuts legacy Spaniol
alias cl='clear'
alias hx='helix'
alias pyp='PYTHONPATH=$(pwd) python'
alias py='python'
alias xp='xplr'
alias cdx='cd $(xplr)'
alias cpx='cp $(xplr) $(xplr)'
alias mvx='mv $(xplr) $(xplr)'
alias rmx='rm $(xplr)'
alias poff='poweroff'
alias rest='reboot'

# Shortcuts brunofs
alias qtdpkg='pacman -Qq | wc -l'
alias mine='cd /home/brunofs/core && java -jar mine.jar'
alias projects='cd ~/core/projetos/'
alias p2='cd ~/core/fgv/cdia/p2'
alias sourcep='source venv/bin/activate'
alias p3='cd ~/core/fgv/cdia/p3'
alias down='echo o | sudo tee /proc/sysrq-trigger'
alias ls='exa -a'
alias shx='sudo HOME=$HOME helix'
alias jp='jupyter notebook'
alias mirror='wl-mirror --fullscreen eDP-1'
alias paclean='sudo pacman -Rns $(pacman -Qdtq)'
alias btop='btop --force-utf'
alias p4='cd ~/core/fgv/cdia/p4'
alias clip='wl-copy'
alias menrank='sudo dmidecode --type memory'
alias mencl='sudo decode-dimms'
alias vd='visidata'
alias timg3='timg * --title --grid=3x'
alias hate='systemctl hibernate'

# Color
#alias ls='ls --color=auto'

