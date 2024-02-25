
# kubernetes aliases
# short alias to set/show context/namespace (only works for bash and bash-compatible shells, 
# current context to be set before using kn to set namespace) 
alias k="kubectl"
alias kx='f() { [ "$1" ] && kubectl config use-context $1 || kubectl config current-context ; } ; f'
alias kn='f() { [ "$1" ] && kubectl config set-context --current --namespace $1 || kubectl config view --minify | grep namespace | cut -d" " -f6 ; } ; f'

