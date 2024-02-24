include () {
  [[ -f "$1" ]] && source "$1"
}

# Public functions and aliases
include ~/.aliases/.aliases_custom_functions
include ~/.aliases/.aliases_git
include ~/.aliases/.aliases_kubernetes
include ~/.aliases/.aliases_utilities

# Personal or private aliases, to avoid mistakenly adding them (added them to .gitignore)
include ~/.aliases/private/.aliases_cldr
include ~/.aliases/private/.aliases_custom
include ~/.aliases/private/.aliases_dc
