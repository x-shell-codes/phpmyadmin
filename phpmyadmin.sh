########################################################################################################################
# Find Us                                                                                                              #
# Author: Mehmet ÖĞMEN                                                                                                 #
# Web   : https://x-shell.codes/scripts/phpmyadmin                                                                     #
# Email : mailto:phpmyadmin.script@x-shell.codes                                                                       #
# GitHub: https://github.com/x-shell-codes/phpmyadmin                                                                  #
########################################################################################################################
# Contact The Developer:                                                                                               #
# https://www.mehmetogmen.com.tr - mailto:www@mehmetogmen.com.tr                                                       #
########################################################################################################################

########################################################################################################################
# Constants                                                                                                            #
########################################################################################################################
NORMAL_LINE=$(tput sgr0)
RED_LINE=$(tput setaf 1)
YELLOW_LINE=$(tput setaf 3)
GREEN_LINE=$(tput setaf 2)
BLUE_LINE=$(tput setaf 4)
POWDER_BLUE_LINE=$(tput setaf 153)
BRIGHT_LINE=$(tput bold)
REVERSE_LINE=$(tput smso)
UNDER_LINE=$(tput smul)

########################################################################################################################
# Line Helper Functions                                                                                                #
########################################################################################################################
function ErrorLine() {
    echo "${RED_LINE}$1${NORMAL_LINE}"
  echo "${RED_LINE}$1${NORMAL_LINE}"
}

function WarningLine() {
    echo "${YELLOW_LINE}$1${NORMAL_LINE}"
  echo "${YELLOW_LINE}$1${NORMAL_LINE}"
}

function SuccessLine() {
    echo "${GREEN_LINE}$1${NORMAL_LINE}"
  echo "${GREEN_LINE}$1${NORMAL_LINE}"
}

function InfoLine() {
    echo "${BLUE_LINE}$1${NORMAL_LINE}"
  echo "${BLUE_LINE}$1${NORMAL_LINE}"
}

########################################################################################################################
# Version                                                                                                              #
########################################################################################################################
function Version() {
  echo "MySQL install script version 1.0.0"
  echo
  echo "${BRIGHT_LINE}${UNDER_LINE}Find Us${NORMAL}"
  echo "${BRIGHT_LINE}Author${NORMAL}: Mehmet ÖĞMEN"
  echo "${BRIGHT_LINE}Web${NORMAL}   : https://x-shell.codes/scripts/phpmyadmin"
  echo "${BRIGHT_LINE}Email${NORMAL} : mailto:phpmyadmin.script@x-shell.codes"
  echo "${BRIGHT_LINE}GitHub${NORMAL}: https://github.com/x-shell-codes/phpmyadmin"
}

########################################################################################################################
# Help                                                                                                                 #
########################################################################################################################
function Help() {
  echo "It install the basic packages required for x-shell.codes projects."
  echo "phpMyAdmin install & configuration script."
  echo
  echo "Options:"
  echo "-p | --password    MySQL dba user password."
  echo "-h | --help        Display this help."
  echo "-V | --version     Print software version and exit."
  echo
  echo "For more details see https://github.com/x-shell-codes/phpmyadmin."
}

########################################################################################################################
# Arguments Parsing                                                                                                    #
########################################################################################################################
password="secret"

for i in "$@"; do
  case $i in
  -p=* | --password=*)
    password="${i#*=}"

    if [ -z "$password" ]; then
      ErrorLine "Password cannot be empty."
      exit
    fi

    shift
    ;;
  -h | --help)
    Help
    exit
    ;;
  -V | --version)
    Version
    exit
    ;;
  -* | --*)
    ErrorLine "Unexpected option: $1"
    echo
    echo "Help:"
    Help
    exit
    ;;
  esac
done

########################################################################################################################
# Main Program                                                                                                         #
########################################################################################################################
echo "${POWDER_BLUE_LINE}${BRIGHT_LINE}${REVERSE_LINE}PHPMYADMIN INSTALLATION${NORMAL_LINE}"

export DEBIAN_FRONTEND=noninteractive

# Kurulum ayarları tanımlanıyor.
debconf-set-selections <<< 'phpmyadmin phpmyadmin/reconfigure-webserver multiselect'
debconf-set-selections <<< 'phpmyadmin phpmyadmin/dbconfig-install boolean true'
debconf-set-selections <<< 'phpmyadmin phpmyadmin/internal/skip-preseed boolean false'
debconf-set-selections <<< 'phpmyadmin phpmyadmin/app-password-confirm password '$password
debconf-set-selections <<< 'phpmyadmin phpmyadmin/mysql/admin-pass password '$password
debconf-set-selections <<< 'phpmyadmin phpmyadmin/mysql/app-pass password '$password

apt install -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" -y --force-yes phpmyadmin

cat > /etc/nginx/snippets/phpmyadmin.conf << EOF
location /phpmyadmin {
    root /usr/share/;
    index index.html index.htm index.php;

    location ~ ^/phpmyadmin/(.+\.php)$ {
        try_files \$uri =404;
        root /usr/share/;
        fastcgi_pass unix:/run/php/php$PHP_VERSION-fpm.sock;
        fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
        include /etc/nginx/fastcgi_params;
    }

    location ~* ^/phpmyadmin/(.+\.(jpg|jpeg|gif|css|png|js|ico|html|xml|txt))$ {
        root /usr/share/;
    }
}

EOF

wget --output-document=phpMyAdmin.zip https://www.phpmyadmin.net/downloads/phpMyAdmin-latest-all-languages.zip    # phpMyAdmin'in son sürümü indiriliyor.
unzip phpMyAdmin.zip -d phpMyAdmin    # İndirilen zip dosyası açılıyor.
rm -rf /usr/share/phpmyadmin/*    # Paket yöneticisinden kurulan phpMyAdmin dosyaları siliyor.
cp -r phpMyAdmin/*/* /usr/share/phpmyadmin/    # İndirilen phpMyAdmin dosyaları kopyalanıyor.
rm -rf phpMyAdmin phpMyAdmin.zip    # İndirilen dosyalar siliyor.

mkdir /usr/share/phpmyadmin/tmp/    # phpMyAdmin temp dizini oluşturuluyor.
sudo chown -R www-data:www-data /usr/share/phpmyadmin/tmp/    # Yetkiler veriliyor.

cat > /usr/share/phpmyadmin/config.inc.php << EOF
<?php

declare(strict_types=1);

\$cfg['blowfish_secret'] = '$(cat /dev/urandom | tr -dc "a-zA-Z0-9" | fold -w 32 | head -n 1)';

EOF
