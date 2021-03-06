#!/bin/bash
set -ux

echo "-+-+-+- start setup. -+-+-+-"

# package update

sudo apt -y update
sudo apt -y upgrade
sudo apt -y dist-upgrade

echo "-+-+-+- package updated complete. -+-+-+-"

# terminal emulator

sudo apt -y install fbterm

# FB の所有グループ（video）に所属させる
sudo usermod -aG video "${USER}"

# SUID を設定（所有者で実行させる）
sudo chmod u+s "$(which fbterm)"

# fbterm のエイリアス等設定
readonly TEMP_REF_BASHRC=https://raw.githubusercontent.com/cresson-cat/initialize-ras-pi/main/reference-files/.bashrc
readonly TEMP_BASHRC=~/.bashrc
[ ! -e "${TEMP_BASHRC}" ] && touch "${TEMP_BASHRC}"
curl "${TEMP_REF_BASHRC}" >>"${TEMP_BASHRC}"

echo "-+-+-+- fbterm configuration complete. -+-+-+-"

# uim

sudo apt -y install \
  uim-fep \
  uim-mozc

# ~/.uim 追記
readonly TEMP_UIM=~/.uim
[ ! -e ${TEMP_UIM} ] && touch ${TEMP_UIM}
cat <<-EOF | sudo tee -a ${TEMP_UIM} >/dev/null
(define default-im-name 'mozc)
(define-key generic-on-key? '("<Alt> "))
(define-key generic-off-key? '("<Alt> "))
EOF

echo "-+-+-+- uim configuration complete. -+-+-+-"

# default key bindings configuration

gsettings set org.gnome.desktop.interface gtk-key-theme "Emacs"

# change caps lock to ctrl key

# XKBOPTIONS="" -> XKBOPTIONS="ctrl:nocaps"
readonly TEMP_KEYBOARD=/etc/default/keyboard
if [ ! -e ${TEMP_KEYBOARD} ]; then
  echo "${TEMP_KEYBOARD}.."
  echo "file not exists. stop the process.."
  exit 1
fi
sudo sed -i -r 's/^XKBOPTIONS=.*/XKBOPTIONS="ctrl:nocaps"/' "${TEMP_KEYBOARD}"

echo "-+-+-+- default key bindings configuration complete. -+-+-+-"

# tools

sudo apt -y install emacs

readonly TEMP_REF_INIT_EL=https://raw.githubusercontent.com/cresson-cat/initialize-ras-pi/main/reference-files/init.el
readonly TEMP_EMACS=~/.emacs.d/init.el
TEMP_EMACS_DIR=$(dirname ${TEMP_EMACS})
readonly TEMP_EMACS_DIR

## If you don't have a init.el, create one.
[ ! -e "${TEMP_EMACS_DIR}" ] && mkdir -p "${TEMP_EMACS_DIR}"
[ ! -e ${TEMP_EMACS} ] && touch ${TEMP_EMACS}
curl ${TEMP_REF_INIT_EL} >${TEMP_EMACS}

echo "-+-+-+- emacs configuration complete. -+-+-+-"

# localization

sudo apt -y install \
  fonts-migmix \
  locales-all

sudo localectl set-locale LANG=ja_JP.UTF-8 LANGUAGE="ja_JP:ja"
# shellcheck source=/dev/null
. /etc/default/locale
## timezone
sudo ln -sf /usr/share/zoneinfo/Asia/Tokyo /etc/localtime &&
  echo Asia/Tokyo | sudo tee /etc/timezone >/dev/null

# fbterm の設定値を変更（font-sizeのみ）
# ※ 設定ファイルは fbterm の初回実行時に作成されるっぽい。追記できないので Github 管理されている資材をコピーする
# sudo sed -i -r 's/^font-size=[0-9]{1-2}/font-size=17/' "${TEMP_FBTERMRC}"
readonly TEMP_REF_FBTERMRC=https://raw.githubusercontent.com/cresson-cat/initialize-ras-pi/main/reference-files/.fbtermrc
readonly TEMP_FBTERMRC=~/.fbtermrc
if [ ! -e ${TEMP_FBTERMRC} ]; then
  curl ${TEMP_REF_FBTERMRC} >${TEMP_FBTERMRC}
fi

echo "-+-+-+- localization complete. -+-+-+-"

echo "-+-+-+- please reboot. -+-+-+-"
