
# Make sure important variables exist if not already defined
#
# $USER is defined by login(1) which is not always executed (e.g. containers)
# POSIX: https://pubs.opengroup.org/onlinepubs/009695299/utilities/id.html
USER=${USER:-$(id -u -n)}

# $HOME is defined at the time of login, but it could be unset. If it is unset,
# a tilde by itself (~) will not be expanded to the current user's home directory.
# POSIX: https://pubs.opengroup.org/onlinepubs/009696899/basedefs/xbd_chap08.html#tag_08_03
HOME="${HOME:-$(getent passwd $USER 2>/dev/null | cut -d: -f6)}"
# macOS does not have getent, but this works even if $HOME is unset
HOME="${HOME:-$(eval echo ~$USER)}"

start=`date +%s`
bold=$(tput bold)
normal=$(tput sgr0)
red=`tput setaf 1`
green=`tput setaf 2`
reset=`tput sgr0`

if test ! $(which gcc); then
  echo "Installing command line developer tools..."
  xcode-select --install
fi

install_update_brew() {
  if test ! $(which brew); then
    echo "Installing homebrew..."
    ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
    brew install caskroom/cask/brew-cask
    brew tap homebrew/cask-versions
    brew tap homebrew/cask-cask
    brew tap 'homebrew/bundle'
    brew tap 'homebrew/cask'
    brew tap 'homebrew/cask-drivers'
    brew tap 'homebrew/cask-fonts'
    brew tap 'homebrew/core'
    brew tap 'homebrew/services'
    brew tap aws/tap
  fi

  brew --version
  echo "Updating homebrew..."
  brew update
  brew upgrade
  brew --version
}

install_update_brew

beginDeploy() {
  echo
  echo "${bold}$1${normal}"
}

function _print_run {
  if [[ :$install_opts: == *:dry-run:* ]]; then
    printf '%s\n' "$BOLD$GREEN[dryrun]$NORMAL $BOLD$*$NORMAL"
  else
    printf '%s\n' "$BOLD\$ $*$NORMAL"
    command "$@"
  fi
}

check_install_tools() {
  local -n _utility_name=$1
  local -n _is_cask_based=$2
  local -n _tool_list=$3

  beginDeploy "############# $_utility_name #############"
  echo "Do you wish to install "${_utility_name}" ${bold}${query}(${bold}${green}y${reset}/${bold}${red}n)${reset}? "
  printf '\t - %s\n' "${_tool_list[@]}"
  read _response

  if [ "$_response" != "${_response#[Yy]}" ] ;then
    echo "Yes, installing $_utility_name Cask($_is_cask_based)"
    if [[  ${_is_cask_based,,} == "yes" ]]; then
      brew install --cask --appdir="/Applications" ${_tool_list[@]}
    else
      brew install ${_tool_list[@]}
    fi
  else
    echo "No, skipping $_utility_name"
  fi
}

echo
echo

############# Mac Application #############
beginDeploy "############# Mac Application #############"
echo -n "Do you wish to install Mac Application (${bold}${green}y${reset}/${bold}${red}n${reset})? "
read MacApplication

MacApplicationToolList=(
  409183694 # Keynote
  409203825 # Numbers
  409201541 # Pages
  497799835 # Xcode
  1450874784 # Transporter
  1274495053 # Microsoft To Do
  1295203466 # Microsoft Remote Desktop 10
  985367838 # Microsoft Outlook
)
if [ "$MacApplication" != "${MacApplication#[Yy]}" ] ;then
  brew install mas
  mas install ${MacApplicationToolList[@]}

  echo "######### Save screenshots to ${HOME}/Pictures/Screenshots"
  defaults write com.apple.screencapture location -string "${HOME}/Pictures/Screenshots"

  echo "######### Save screenshots in PNG format (other options: BMP, GIF, JPG, PDF, TIFF"
  defaults write com.apple.screencapture type -string "png"
else
  echo No
fi


############# General Tools #############
tool_type="General Tools"
is_cask_based="yes"
CaskGeneralToolList=(
  google-chrome
  firefox
  spotify
)
check_install_tools tool_type is_cask_based CaskGeneralToolList


############# Designer #############
tool_type="Designer Tools"
is_cask_based="yes"
CaskDesignerToolList=(
  adobe-creative-cloud
)
check_install_tools tool_type is_cask_based CaskDesignerToolList

############# Mobile Development #############
tool_type="Mobile Development Tools"
is_cask_based="yes"
CaskMobileDeveloperToolList=(
  fastlane
)
check_install_tools tool_type is_cask_based CaskMobileDeveloperToolList

############# Cloud Development #############
tool_type="Cloud Development Tools"
is_cask_based="no"
CaskCloudDevelopmentToolList=(
  gimme-aws-creds
  awscli
  aws-sam-cli
)
check_install_tools tool_type is_cask_based CaskCloudDevelopmentToolList

############# Python Developer tools #############
tool_type="Python Developer tools"
is_cask_based="no"
PythonUtilitiesList=(
  python
)
check_install_tools tool_type is_cask_based PythonUtilitiesList

function install_python_libraries() {
  pip3 install virtualenv
}
install_python_libraries

############# Nodejs Developer tools #############
tool_type="Nodejs Developer tools"
is_cask_based="no"
NodejsUtilitiesList=(
  node
  nvm
  yarn
  yarn-completion
)
check_install_tools tool_type is_cask_based NodejsUtilitiesList

function configure_nvm() {
  # Configure NVM
  if [ ! -d "$HOME/.nvm" ]; then
    mkdir $HOME/.nvm
    echo '
# NVM CONFIG
export NVM_DIR="$HOME/.nvm"
[ -s "$(brew --prefix)/opt/nvm/nvm.sh" ] && . "$(brew --prefix)/opt/nvm/nvm.sh" # This loads nvm
[ -s "$(brew --prefix)/opt/nvm/etc/bash_completion.d/nvm" ] && . "$(brew --prefix)/opt/nvm/etc/bash_completion.d/nvm" # This loads nvm bash_completion' >> $HOME/.bash_profile
  fi

}
configure_nvm

############# Go Development tools #############
tool_type="Go Developer tools"
is_cask_based="no"
GoUtilitiesList=(
  go
)
check_install_tools tool_type is_cask_based GoUtilitiesList

function install_go_libraries() {
  # install kubebuilder https://book.kubebuilder.io/quick-start.html#installation
  if [ ! -f /usr/local/bin/kubebuilder ]; then
    echo "Install kubebuilder"
    curl -L -o kubebuilder "https://go.kubebuilder.io/dl/latest/$(go env GOOS)/$(go env GOARCH)"
    chmod +x kubebuilder && sudo mv kubebuilder /usr/local/bin/
  fi
}
install_go_libraries

############# Developer Utilities #############
tool_type="Developer Utilities"
is_cask_based="no"
DeveloperUtilitiesList=(
  ctop
  jq
  nmap
  wget
  tree
  bash-completion
#  httpie
#  netcat
)
check_install_tools tool_type is_cask_based DeveloperUtilitiesList

function post_utility_setup() {
  echo '
# BASH-COMPLETION CONFIG
[[ -r "$(brew --prefix)/etc/profile.d/bash_completion.sh" ]] && . "$(brew --prefix)/etc/profile.d/bash_completion.sh"' >> $HOME/.bash_profile
}
post_utility_setup

############# Database Tools #############
tool_type="Database Tools"
DatabaseToolList=(
  kafkacat
)
check_install_tools tool_type "no" DatabaseToolList
CaskDatabaseToolList=(
  pgadmin4
  studio-3t
  graphiql
  azure-data-studio
)
check_install_tools tool_type "yes" CaskDatabaseToolList


############# IDEs #############
tool_type="IDEs"
is_cask_based="yes"
CaskIDEsList=(
  visual-studio-code
  intellij-idea
  visual-studio
  android-studio
)
check_install_tools tool_type is_cask_based CaskIDEsList


############# DevOps #############
tool_type="DevOps"
is_cask_based="no"
DevOpsToolList=(
  terraform
  vault
  consul
  nomad
  packer
  terragrunt
  ansible
  kompose
)
check_install_tools tool_type is_cask_based DevOpsToolList

is_cask_based="yes"
CaskDevOpsToolList=(
  docker
  vagrant
  vagrant-manager
  virtualbox
  vmware-fusion
)
check_install_tools tool_type is_cask_based CaskDevOpsToolList


############# Productivity Tools #############
tool_type="Productivity Tools"
is_cask_based="yes"
CaskProductivityToolList=(
  slack
#   evernote
#   the-unarchiver
  dash
#   gpg-suite
#   microsoft-teams
#   microsoft-office
  zoomus
)
check_install_tools tool_type is_cask_based CaskProductivityToolList



beginDeploy "############# CLEANING HOMEBREW #############"
brew cleanup

beginDeploy "############# GLOBAL GIT CONFIG #############"
unset response
echo -n "Do you wish to configure git (${bold}${green}y${reset}/${bold}${red}n${reset})? "
read response
if [ "$response" != "${response#[Yy]}" ]; then
  sh -c 'curl -s https://raw.githubusercontent.com/niteshy/dev-env-setup/main/src/dotfiles/.gitconfig > $HOME/.gitconfig'
  sh -c 'curl -s https://raw.githubusercontent.com/niteshy/dev-env-setup/main/src/dotfiles/.gitignore > $HOME/.gitignore'

  echo -n "What is the git (${bold}${green}user name${reset})? "
  read Username
  echo -n "What is the git (${bold}${green}user email id${reset})? "
  read UserEmail
  git config --global --replace-all user.name "$Username"
  git config --global --replace-all user.email "$UserEmail"
fi

beginDeploy "############# COPYING ALIASES #################"
echo -n "Do you wish to copy aliases (${bold}${green}y${reset}/${bold}${red}n${reset})? "
read response
if [ "$response" != "${response#[Yy]}" ]; then
  _print_run mkdir -p $HOME/.aliases

  sh -c 'curl -s https://raw.githubusercontent.com/niteshy/dev-env-setup/main/src/dotfiles/.aliases/.aliases.custom_functions.bashrc > $HOME/.aliases/.aliases.custom_functions.bashrc'
  sh -c 'curl -s https://raw.githubusercontent.com/niteshy/dev-env-setup/main/src/dotfiles/.aliases/.aliases.docker.bashrc > $HOME/.aliases/.aliases.docker.bashrc'
  sh -c 'curl -s https://raw.githubusercontent.com/niteshy/dev-env-setup/main/src/dotfiles/.aliases/.aliases.git.bashrc > $HOME/.aliases/.aliases.git.bashrc'
  sh -c 'curl -s https://raw.githubusercontent.com/niteshy/dev-env-setup/main/src/dotfiles/.aliases/.aliases.kubernetes.bashrc > $HOME/.aliases/.aliases.kubernetes.bashrc'
  sh -c 'curl -s https://raw.githubusercontent.com/niteshy/dev-env-setup/main/src/dotfiles/.aliases/.aliases.utilities.bashrc > $HOME/.aliases/.aliases.utilities.bashrc'
  sh -c 'curl -s https://raw.githubusercontent.com/niteshy/dev-env-setup/main/src/dotfiles/.jq > $HOME/.jq'
fi

function update_bashrc {
  printf '%s\n' "${BLUE}Looking for an existing bash config...${NORMAL}"
  if [[ -f ~/.bashrc || -h ~/.bashrc ]]; then
    # shellcheck disable=SC2155
    local bashrc_backup=~/.bashrc.des-backup-$(date +%Y%m%d%H%M%S)
    printf '%s\n' "${YELLOW}Found ~/.bashrc.${NORMAL} ${GREEN}Backing up to $bashrc_backup${NORMAL}"
    _print_run mv ~/.bashrc "$bashrc_backup"
  fi
  printf '%s\n' "${BLUE}Copying the Bashrc template to ~/.bashrc${NORMAL}"
}

beginDeploy "############# SETUP BASH PROFILE #############"
echo -n "Do you wish to setup bash profile (${bold}${green}y${reset}/${bold}${red}n${reset})? "
read response
if [ "$response" != "${response#[Yy]}" ]; then
  update_bashrc
  sh -c 'curl -s https://raw.githubusercontent.com/niteshy/dev-env-setup/main/src/dotfiles/.bashrc > $HOME/.bashrc'
  source $HOME/.bashrc
fi

runtime=$((($(date +%s)-$start)/60))
beginDeploy "############# Total Setup Time = $runtime Minutes #############"