#!/usr/bin/env bash
# Idempotent environment bootstrap for the Le Wagon dotfiles repo.
# Installs the toolset the dotfiles target (zsh + oh-my-zsh + plugins, ruby)
# so an agent can edit a dotfile and verify it loads cleanly under zsh.
set -euo pipefail

echo "-----> Installing system packages (zsh, ruby, locales)"
export DEBIAN_FRONTEND=noninteractive
sudo apt-get update -y
sudo apt-get install -y --no-install-recommends \
  zsh ruby-full build-essential git curl ca-certificates vim less locales

# The zshrc sets LANG/LC_ALL to en_US.UTF-8; make sure that locale exists.
if ! locale -a 2>/dev/null | grep -qiE '^en_US\.utf-?8$'; then
  echo "-----> Generating en_US.UTF-8 locale"
  sudo sed -i 's/^# *\(en_US.UTF-8\)/\1/' /etc/locale.gen
  sudo locale-gen en_US.UTF-8
fi

# Install oh-my-zsh unattended (the zshrc sources it from ~/.oh-my-zsh).
if [ ! -d "$HOME/.oh-my-zsh" ]; then
  echo "-----> Installing oh-my-zsh"
  RUNZSH=no CHSH=no KEEP_ZSHRC=yes \
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
else
  echo "-----> oh-my-zsh already installed"
fi

# Install the one external zsh plugin referenced by zshrc.
# (git, gitfast, last-working-dir, common-aliases, sublime and
#  history-substring-search all ship with oh-my-zsh.)
ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
PLUGIN_DIR="$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
if [ ! -d "$PLUGIN_DIR" ]; then
  echo "-----> Installing zsh plugin 'zsh-syntax-highlighting'"
  git clone --depth 1 https://github.com/zsh-users/zsh-syntax-highlighting.git "$PLUGIN_DIR"
else
  echo "-----> zsh plugin 'zsh-syntax-highlighting' already installed"
fi

echo "-----> Environment ready. Ruby: $(ruby --version), zsh: $(zsh --version)"
