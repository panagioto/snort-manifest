#!/bin/bash


libdnet_link="http://sourceforge.net/projects/libdnet/files/libdnet/libdnet-1.11/libdnet-1.11.tar.gz"
daq_link="https://www.snort.org/downloads/snort/daq-2.0.6.tar.gz"
snort_link="https://snort.org/downloads/snort/snort-2.9.7.6.tar.gz"
pulledpork_link="https://pulledpork.googlecode.com/files/pulledpork-0.7.0.tar.gz"
yaml_link="pyyaml.org/download/libyaml/yaml-0.1.6.zip"
ruby_link="cache.ruby-lang.org/pub/ruby/1.9/ruby-1.9.3-p547.tar.gz"
imagemagick_link="www.imagemagick.org/download/ImageMagick.tar.gz"
wkhtmltopdf_link="http://download.gna.org/wkhtmltopdf/0.12/0.12.2.1/wkhtmltox-0.12.2.1_linux-centos6-amd64.rpm"


RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
NORMAL=$(tput sgr0)

echo 

#disable selinux for installation
setenforce 0 &> /dev/null
#disable selinux permantly
sed -i '/^SELINUX=/s/enforcing/disabled/' /etc/selinux/config 

while [ 1 ]
do
 read -p "Insert root password for mysql: " -s mypass
 echo
 read -p "Insert root password for mysql again: " -s my_pass
 if [ $mypass != $my_pass ]
  then
   echo -e "\nPasswords did not match."
   echo
 else
  echo
  echo
  break
 fi
done

 
read -p "Insert oinkcode: " oinkcode
echo
read -p "Insert the snorby front-end hostname: " host_name
echo

#update and install requiered packages
printf "Updating and installing required packages"
yum update -y &> /dev/nvull

yum -y install vim wget man make gcc flex bison zlib zlib-devel libpcap libpcap-devel pcre pcre-devel tcpdump gcc-c++ mysql-server mysql mysql-devel libtool perl-libwww-perl perl-Archive-Tar perl-Crypt-SSLeay git gcc libxml2 libxml2-devel libxslt libxslt-devel httpd curl-devel httpd-devel apr-devel apr-util-devel libXrender fontconfig libXext ruby-devel unzip xz fontconfig-devel libX11-devel libXext-devel libXrender-devel readline-devel urw-fonts fontconfig-devel libX11-devel libXext-devel libXrender-devel readline-devel urw-fonts xorg-x11-fonts-Type1 xorg-x11-fonts-75dpi libjpeg-turbo libpng &> /dev/null


printf '%*s' 23 "[$GREEN OK $NORMAL]"
echo
echo

#check for libdnet
printf 'Checking link for libdnet-1.11'
if curl -s --head  --request GET "$libdnet_link" | grep "302 Found" > /dev/null
 then
  printf '%*s' 34 "[$GREEN OK $NORMAL]"
  echo
else
  printf '%*s' 34 "[$RED FAIL $NORMAL]"
  echo
  exit
fi

#check for daq
printf 'Checking link for daq-2.0.6'
if curl -s --head  --request GET "$daq_link" | grep "302 Found" > /dev/null
 then
  printf '%*s' 37 "[$GREEN OK $NORMAL]"
  echo
else
  printf '%*s' 37 "[$RED FAIL $NORMAL]"
  echo
  exit
fi

#check for snort
printf 'Checking link for snort-2.9.7.6'
if curl -s --head  --request GET "$snort_link" | grep "302 Found" > /dev/null
 then
  printf '%*s' 33 "[$GREEN OK $NORMAL]"
  echo
else
  printf '%*s' 33 "[$RED FAIL $NORMAL]"
  echo
  exit
fi

printf 'Checking link for pulledpork-0.7.0'
if curl -s --head  --request GET "$pulledpork_link" | grep "200 OK" > /dev/null
 then
  printf '%*s' 30 "[$GREEN OK $NORMAL]"
  echo
else
  printf '%*s' 30 "[$RED FAIL $NORMAL]"
  echo
  exit
fi

#check for yaml
printf 'Checking link for yaml-0.1.6'
if curl -s --head  --request GET "$yaml_link" | grep "200 OK" > /dev/null
 then
  printf '%*s' 36 "[$GREEN OK $NORMAL]"
  echo
else
  printf '%*s' 36 "[$RED FAIL $NORMAL]"
  echo
  exit
fi

#check for ruby
printf 'Checking link for ruby-1.9.3'
if curl -s --head  --request GET "$ruby_link" | grep "200 OK" > /dev/null
 then
  printf '%*s' 36 "[$GREEN OK $NORMAL]"
  echo
else
  printf '%*s' 36 "[$RED FAIL $NORMAL]"
  echo
  exit
fi

#check for ImageMagick
printf 'Checking link for ImageMagick'
if curl -s --head  --request GET "$imagemagick_link" | grep "200 OK" > /dev/null
 then
  printf '%*s' 35 "[$GREEN OK $NORMAL]"
  echo
else
  printf '%*s' 35 "[$RED FAIL $NORMAL]"
  echo
  exit
fi

#check for wkhtmltopdf
printf 'Checking link for wkhtmltopdf'
if curl -s --head  --request GET "$wkhtmltopdf_link" | grep "200 OK" > /dev/null
 then
  printf '%*s' 35 "[$GREEN OK $NORMAL]"
  echo
else
  printf '%*s' 35 "[$RED FAIL $NORMAL]"
  echo
  exit
fi


######################################################################################################################################################################
echo 

#start mysql and set mysql root password
/etc/init.d/mysqld start &> /dev/null
mysqladmin -u root password $mypass > /dev/null


#compile from source prerequest packets for snort

#download libdnet
echo "Installing libdnet..."
cd /usr/local/src
wget -qO- "$libdnet_link" | tar xvz > /dev/null
cd libdnet*
./configure -with-pic &> /dev/null
{
make && make install
} &> /dev/null


#download daq
echo "Installing daq..."
cd /usr/local/src
wget -qO- "$daq_link" | tar xvz > /dev/null
cd daq*
./configure &> /dev/null
{
make && make install
} &> /dev/null

#snort install
echo "Installing snort..."
cd /usr/local/src
wget -qO- "$snort_link" | tar xvz > /dev/null
cd snort*
./configure --enable-sourcefire &> /dev/null
{
make && make install
} &> /dev/null

#snort configurationA
echo "Configuring snort..."
mkdir -p /etc/snort/rules
mkdir -p /var/log/snort/eth0
mkdir /var/log/barnyard2
mkdir -p /usr/local/lib/snort_dynamicrules
mkdir /etc/snort/rules/iplists
touch /etc/snort/rules/iplists/default.blacklist
touch /etc/snort/rules/black_list.rules
touch /etc/snort/rules/white_list.rules
touch /etc/snort/rules/local.rules
touch /var/log/snort/eth0/barnyard2.waldo
touch /etc/snort/sid-msg.map

cp etc/* /etc/snort

groupadd -g 40000 snort &> /dev/null
useradd snort -u 40000 -d /var/log/snort -s /sbin/nologin -c SNORT_IDS -g snort &> /dev/null
cd /etc/snort
chown -R snort:snort *
chown -R snort:snort /var/log/snort

#####################################################################################################################


#snort.conf configuration DO NOT FORGET TO SET HOME_NET DNS etc
######################################
sed -i -e '/^include \$RULE_PATH/s/^/#/' -e '/^var RULE_PATH/s/\.\.\/rules/\/etc\/snort\/rules/' -e '/^var SO_RULE/s/\.\.\/so_rules/so_rules/' \
	-e '/^var PREPROC/s/\.\.\/.*/preproc_rules/' -e '/^var WHITE/s/\.\..*/\/etc\/snort\/rules/' -e '/^var BLACK/s/\.\..*/\/etc\/snort\/rules/' \
	-e '/# unified2/a output unified2: filename snort.log, limit 128' -e '/^dynamicdetection/s/^/#/' -e '/^ipvar HOME_NET/s/any/192.168.0.0\/24/' \
	-e '/^ipvar EXTERNAL_NET/s/any/!\$HOME_NET/' /etc/snort/snort.conf

sed -i -e '/#include.*local\.rules/s/#//' /etc/snort/snort.conf

######################################

cd /usr/local/src
chown -R snort:snort daq*
chown -R snort:snort snort*
chown -R snort:snort snort_dynamicsrc
chmod -R 700 daq*
chmod -R 700 snort*
chmod -R 700 snort_dynamicsrc

cd snort*
cp rpm/snortd /etc/init.d/snort
cp rpm/snort.sysconfig /etc/sysconfig/snort

chmod 700 /etc/init.d/snort
chmod 700 /etc/sysconfig/snort

cd /usr/sbin
ln -s /usr/local/bin/snort snort

#snort init.d configuration and snort sysconfig configuration
######################################
cp /etc/sysconfig/snort /etc/sysconfig/snort_default
sed -i -e '/PASS_FIRST/s/^/#/' -e '/^ALERTMODE/s/^/#/' -e '/^DUMP_APP/s/^/#/' -e '/^BINARY_LOG/s/^/#/' -e '/^NO_PACKET_LOG/s/^/#/' -e '/^PRINT_INTERFACE/s/^/#/' /etc/sysconfig/snort
######################################

cd /var/log
chmod 700 snort
chown -R snort:snort snort
cd /usr/local/lib
chown -R snort:snort snort*
chown -R snort:snort snort_dynamic*
chown -R snort:snort pkgconfig
chmod -R 700 snort*
chmod -R 700 pkgconfig
cd /usr/local/bin
chown -R snort:snort daq-modules-config
chown -R snort:snort u2*
chmod -R 700 daq-modules-config
chmod 700 u2*
cd /etc
chown -R snort:snort snort
chmod -R 700 snort

#install barnyard2
echo "Installing barnyard2..."
cd /usr/local/src
git clone https://github.com/firnsy/barnyard2.git &> /dev/null
cd barnyard2
./autogen.sh &> /dev/null
./configure --with-mysql -with-mysql-libraries=/usr/lib64/mysql &> /dev/null
{
make && make install
} &> /dev/null

cp /usr/local/etc/barnyard2.conf /etc/snort
cp etc/barnyard2.conf /etc/snort
cp rpm/barnyard2 /etc/init.d
chmod 700 /etc/init.d/barnyard2
cp rpm/barnyard2.config /etc/sysconfig/barnyard2

#barnyard.conf configuration
echo "Configuring barnyard2..."
echo "output database: log, mysql, user=root password=$mypass dbname=snorby host=localhost" >> /etc/snort/barnyard2.conf

#/etc/init.d/barnayrd2 config and /etc/sysconfig
cp /etc/init.d/barnyard2 /etc/init.d/barnyard2_default
sed -i -e '/BARNYARD_OPTS=/s/$SNORTDIR\/${INT}/$SNORTDIR/' -e '/BARNYARD_OPTS=/s/-L \$SNORTDIR\/\${INT}/-l $SNORTDIR/' -e '/"b.*2"/s/barnyard2/\/usr\/local\/bin\/barnyard2/' -e '/touch \/var/s/\$prog/barnyard2/' /etc/init.d/barnyard2

sed -i 's#$SNORTDIR/${INT}#$SNORTDIR#g' /etc/init.d/barnyard2

cp /etc/sysconfig/barnyard2 /etc/sysconfig/barnyard2_default
sed -i '/CONF=/s/barnyard.conf/barnyard2.conf/' /etc/sysconfig/barnyard2
sed -i '/LOG_FILE=/s/"snort_unified.log"/"snort.log"/' /etc/sysconfig/barnyard2

#install pulledpork
echo "Installing pulledpork..."
cd /usr/local/src
wget -qO- "$pulledpork_link" | tar -xvz > /dev/null
cd pulledpork*
cp pulledpork.pl /usr/local/bin/pulledpork
chmod 700 /usr/local/bin/pulledpork
cp etc/* /etc/snort

#pulledpork.conf configuration and set alias to .bashrc for new rules and how to run pulledpork DO NOT FORGET oinkcode
cp /etc/snort/pulledpork.conf pulledpork.conf_default

sed -i[conf] -e '/^local_rules=/s/\/usr.*/\/etc\/snort\/rules\/local.rules/' -e '/^rule_path/s/\/usr.*/\/etc\/snort\/rules\/snort.rules/' \
	-e '/sid_msg=/s/\/usr.*/\/etc\/snort\/sid-msg.map/' -e '/config_path=/s/\usr.*/\etc\/snort\/snort.conf/' -e '/black_list=/s/\/usr.*/\/etc\/snort\/rules\/iplists\/default.blacklist/' \
	-e '/IPRV/s/\/usr.*/\/etc\/snort\/rules\/iplists/' -e "/^rule.*oinkcode/s/<oinkcode>/$oinkcode/" /etc/snort/pulledpork.conf

echo "alias pulledpork='/usr/local/bin/pulledpork -c /etc/snort/pulledpork.conf -C /etc/snort/snort.conf -P -I security -e /etc/snort/enablesid.conf -i /etc/snort/disablesid.conf -M /etc/snort/modifysid.conf -v'" >> ~/.bashrc

echo "alias new_rules='pulledpork && service barnyard2 restart && service snort restart'" >> ~/.bashrc

alias pulledpork='/usr/local/bin/pulledpork -c /etc/snort/pulledpork.conf -C /etc/snort/snort.conf -P -I security -e /etc/snort/enablesid.conf -i /etc/snort/disablesid.conf -M /etc/snort/modifysid.conf -v' &> /dev/null
alias new_rules='pulledpork && service barnyard2 restart && service snort restart' &> /dev/null


#install snorby

#first we have to install ruby version > 1.9.x.In order to install ruby first we have to install libyaml
echo "Installing yaml..."
cd /usr/local/src
wget -q -O yaml.zip "$yaml_link" && unzip yaml.zip > /dev/null && rm -f yaml.zip
cd yaml*
./configure &> /dev/null
{
make && make install 
} &> /dev/null

#install ruby
echo "Installing ruby..."
cd /usr/local/src
wget -qO- "$ruby_link" | tar -xvz > /dev/null
cd ruby*
./configure &> /dev/null
{
make && make install
} &> /dev/null

#now install rails
echo "Installing rails..."
gem install rails &> /dev/null

#install ImageMagick
echo "Installing ImageMagick..."
cd /usr/local/src
wget -qO- "$imagemagick_link" | tar -xvz > /dev/null
cd ImageMagick*
./configure &> /dev/null
{
make && make install
} &> /dev/null

#install wkhtmltopdf
echo "Installing wkhtmltopdf..."
cd /usr/local/src
wget "$wkhtmltopdf_link" &> /dev/null
rpm -i wkhtml*.rpm &> /dev/null

#now install snorby
cd /usr/local/src
git clone https://github.com/Snorby/snorby.git

#before we install snorby via bundle we have to install another gem called nokogiri and bundler
echo "Installing ruby gems..."
gem install nokogiri -- --use-system-libraries &> /dev/null
gem install bundler &> /dev/null

cd snorby
bundle install --deployment &> /dev/null

echo "Installing snorby..."
#before set up snorby database we have to edit database.yml and snorby_config.yml in /usr/local/src/snorby/config
cp /usr/local/src/snorby/config/database.yml.example /usr/local/src/snorby/config/database.yml
sed -i "/password/s/Enter Password Here/$mypass/" /usr/local/src/snorby/config/database.yml

#read -p "Give the hostname for the snorby front-end " host_name
cp /usr/local/src/snorby/config/snorby_config.yml.example /usr/local/src/snorby/config/snorby_config.yml
sed -i -e 's/^.*""/    - "\/etc\/snort\/rules"/' -e "s/demo.snorby.org/$host_name/" /usr/local/src/snorby/config/snorby_config.yml

bundle exec rake snorby:setup &> /dev/null

#configure iptables to accept traffic to port 80
cp /etc/sysconfig/iptables /etc/sysconfig/iptables_default
sed -i '/22/a -A INPUT -m state --state NEW -m tcp -p tcp --dport 80 -j ACCEPT' /etc/sysconfig/iptables
/etc/init.d/iptables restart &> /dev/null

#chkconfig the apropriate services
#not chkconfig barnyard2 because we have to ensure that mysql starts first
chkconfig httpd on
chkconfig mysqld on
chkconfig snort on


#install passenger last in order to take the settings that give us to put inside apache's conf
echo "Installing passenger..."
gem install passenger &> /dev/null
passenger-install-apache2-module --auto &> /dev/null

#run barnyard2 with hand in order to avoid waldo file problem tha occurs with init script
#barnyard2 -c /etc/snort/barnyard2.conf -d /var/log/snort/ -f snort.log -w /var/log/snort/eth0/barnyard2.waldo &


pass_vers=`gem search passenger | grep -Po '(?<=\().*?(?=\))'`
echo "
LoadModule passenger_module /usr/local/lib/ruby/gems/1.9.1/gems/passenger-"$pass_vers"/buildout/apache2/mod_passenger.so
 <IfModule mod_passenger.c>
   PassengerRoot /usr/local/lib/ruby/gems/1.9.1/gems/passenger-"$pass_vers"
   PassengerDefaultRuby /usr/local/bin/ruby
 </IfModule>
 <VirtualHost *:80>
  ServerName www.yourhost.com
  # !!! Be sure to point DocumentRoot to 'public'!
  DocumentRoot /usr/local/src/snorby/public
  <Directory /usr/local/src/snorby/public>
   # This relaxes Apache security settings.
   AllowOverride all
   # MultiViews must be turned off.
   Options -MultiViews
   # Uncomment this if you're on Apache >= 2.4:
   #Require all granted
  </Directory>
</VirtualHost>
" >> /etc/httpd/conf/httpd.conf




echo "Fetching snort rules..."
/usr/local/bin/pulledpork -c /etc/snort/pulledpork.conf -C /etc/snort/snort.conf -P -I security -e /etc/snort/enablesid.conf -i /etc/snort/disablesid.conf -M /etc/snort/modifysid.conf -v &> /dev/null

service httpd restart &> /dev/null
service barnyard2 stop &> /dev/null
service mysqld stop &> /dev/null
service snort stop &> /dev/null

service mysqld start
service snort start
service barnyard2 start

#snorby worker
echo "Starting snorby worker..."
cd /usr/local/src/snorby
RAILS_ENV=production script/rails r "Snorby::Worker.stop" &> /dev/null
RAILS_ENV=production script/rails r "Snorby::Worker.start" &> /dev/null
RAILS_ENV=production script/rails r "Snorby Cache Jobs" &> /dev/null
RAILS_ENV=production script/rails r "Snorby::Jobs::SensorCacheJob.new(true).perform" &> /dev/null
RAILS_ENV=production script/rails r "Snorby::Jobs::DailyCacheJob.new(true).perform" &> /dev/null
RAILS_ENV=production script/rails r "Snorby::Jobs.clear_cache" &> /dev/null
RAILS_ENV=production script/rails r "Snorby::Jobs.run_now" &> /dev/null
RAILS_ENV=production script/rails r "Snorby::Jobs::GeoipUpdatedbJob.new(true).perform" &> /dev/null


echo 
echo "DONE!"
