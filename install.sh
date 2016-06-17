#!/bin/bash

sudo apt-get update && upgrade
sudo apt-get install apache2 apache2-utils samba -y
sudo apt-get install openssh-server -y
sudo apt-get install mysql-server libapache2-mod-auth-mysql php5-mysql -y
sudo mysql_install_db
sudo apt-get install php5 libapache2-mod-php5 php5-mcrypt curl php5-curl -y
curl -sS https://getcomposer.org/installer | sudo php -- --install-dir=/usr/local/bin --filename=composer

##
# create a new user
##
create_new_user() {
    sudo su -c "useradd sharonypark"
    sudo chpasswd << 'END'
sharonypark:password
END
}

##
# create sharonypark.com dir
##
create_dir() {
    mkdir /var/www/sharonypark.com
    sudo sh -c "chown sharonypark:www-data /var/www/sharonypark.com"
    sudo sh -c "chmod 775 /var/www/sharonypark.com"
}

##
# setup_samba
# setups and install dev samba server
##
setup_samba() {

    #sudo apt-get install samba

    SAMBA_CFG=/etc/samba/smb.conf

    if grep -q sharonypark "$SAMBA_CFG"; then
        echo "samba already configured";
    else
        # write to smb.cfg
        echo "Writing to samba cfg file /etc/samba/smb.cfg";
        sudo sh -c "echo \" # sharonypark configuration\" >> $SAMBA_CFG";
        sudo sh -c "echo \"[share]\" >> $SAMBA_CFG";
        sudo sh -c "echo \"path = /var/www/sharonypark.com\" >> $SAMBA_CFG";
        sudo sh -c "echo \"read only = no\" >> $SAMBA_CFG";
        sudo sh -c "echo \"create mask = 0755\" >> $SAMBA_CFG";
        
        # create sharonypark dir
        create_dir

        # add a user to samba
        (echo "password"; echo "password") | sudo sh -c "smbpasswd -a sharonypark"
        # restart samba
        sudo service smbd restart
    fi
}

##
# download_from_git
# downloads repo from git and changes directory ownership 
# and chmods the storage dir
##
download_from_git() {
    git clone https://github.com/john-ko/sharonypark.git /var/www/sharonypark.com
    sudo sh -c "chown sharonypark:www-data /var/www/sharonypark.com -R"
    sudo sh -c "chmod -R 777 /var/www/sharonypark.com/storage"
}

##
# setup_apache_vhost
# sets up sharonypark directory in apache
##
setup_apache_vhost() {
    SYP_CONF=/etc/apache2/sites-available/sharonypark.conf
    cat << 'EOF' > $SYP_CONF
<VirtualHost *:80>
    DocumentRoot /var/www/sharonypark.com/public
    ErrorLog ${APACHE_LOG_DIR}/sharon-error.log
    CustomLog ${APACHE_LOG_DIR}/sharon-access.log combined
</VirtualHost>
EOF
    
    # reload and restarts
    sudo a2dissite 000-default
    sudo a2ensite sharonypark
    sudo service apache2 reload
}

##
# install_sharonypark
# installs using composer
##
install_sharonypark() {
    composer global require "laravel/installer"
    cd /var/www/sharonypark.com
    composer install
}

# create a new user
create_new_user

# calls setup_samba function
setup_samba

# download the repo
download_from_git

# installs
install_sharonypark

# setup apache2
setup_apache_vhost