#!/bin/bash

cat << "EOF"

-----------------------------------------------------------------------------
Projeto

 ██████  ██████  ███████ ███    ██  ██████ ████████ ██    ██████  ██████  
██    ██ ██   ██ ██      ████   ██ ██         ██    ██    ██   ██ ██   ██ 
██    ██ ██████  █████   ██ ██  ██ ██         ██    ██    ██████  ██████  
██    ██ ██      ██      ██  ██ ██ ██         ██    ██    ██   ██ ██   ██ 
 ██████  ██      ███████ ██   ████  ██████    ██    ██ ██ ██████  ██   ██


-----------------------------------------------------------------------------


 * Script de instalacao do OpenVPN e Honeypots: Dionea, Cowrie e Suricata.
 * Homologado em Ubuntu 16.04
 * honeypot@opencti.net.br | https://github.com/openctibr


EOF


sleep 5

#Creating SWAP
dd if=/dev/zero of=/swpfile bs=1M count=1024
chmod 0600 /swpfile 
mkswap /swpfile
echo "/swpfile none swap defaults 0 0" >> /etc/fstab
swapon -a


if [ -d "/opt/dionaea" ] 
then
    supervisorctl stop all
    rm -rf /opt/*
    rm -rf /etc/supervisor/conf.d/*
fi

##################################################
# Instalacao do cliente OpenVPN em Ubuntu 16.04  #
# honeypot@opencti.net.br                        #
##################################################

# Clean iptable Rules
iptables -F
iptables -X
iptables -Z

#Remove RPCBind
apt-get -y remove --purge rpcbind

# Install dependencies
apt-get update
apt-get -y install locales
apt-get -y install build-essential libpcap-dev dialog rsyslog libjansson-dev libpcre3-dev libdnet-dev libdumbnet-dev libdaq-dev flex bison python-pip git make automake libtool zlib1g-dev
apt-get -y install python-dev git supervisor authbind openssl python-virtualenv build-essential python-gmpy2 libgmp-dev libmpfr-dev libmpc-dev libssl-dev python-pip libffi-dev
apt-get -y install git python-pip supervisor golang build-essential cmake check cython3 libcurl4-openssl-dev libemu-dev libev-dev libglib2.0-dev libloudmouth1-dev libnetfilter-queue-dev libnl-3-dev libpcap-dev libssl-dev libtool libudns-dev python3 python3-dev python3-bson python3-yaml python3-boto3 supervisor zip unzip

#Creating LOG
su -c "echo ." root

# Installing Fail2Ban
apt-get -y install fail2ban

#Change OpenSSH Port
sed -i 's/^#Port 22$/Port 2222/g' /etc/ssh/sshd_config
sed -i 's/^Port 22$/Port 2222/g' /etc/ssh/sshd_config
/etc/init.d/ssh restart

#Protecting SSHD Port
echo "port     = 2222" >> /etc/fail2ban/jail.d/defaults-debian.conf
systemctl enable fail2ban
systemctl restart fail2ban


#ADD OpenVPN REPO
curl -s https://swupdate.openvpn.net/repos/repo-public.gpg | apt-key add -
echo "deb http://build.openvpn.net/debian/openvpn/stable xenial main" > /etc/apt/sources.list.d/openvpn-aptrepo.list

#Add User OpenCTI.BR
useradd -d /home/opencti -s /bin/bash -m opencti -g sudo

#Chaning Sudoers
sed -i 's/ALL=(ALL:ALL) ALL/ALL=(ALL) NOPASSWD: ALL/g' /etc/sudoers

#Adding SSHPrivKey
su -c 'echo "y" | ssh-keygen  -N "" -f /home/opencti/.ssh/id_rsa'  opencti

#Adding SSHAuthKey
su -c 'echo "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDY/a8vrkGarGVb5+v6ZwxcYRX3JL+sRwKdP1tN9ZCZTs6/MRZWggRny6Ewp9J4D3uKiOV2LbGY2HlgkTf0nMHz/YTIfxj0tbI55d1si98zxMNBw0cmGVI2xFCP30SiTcaCAD+fqtcaWt7qW60g7rnHJCKVmwQY0K4YMG95u0PS+1TzmwGJdUazO8KBWzbsb/SqkchyKoTT7K5VC9rsNW6QX7VCopTqD7qriRCvn1eZ359cnWlnNynfcg2QDDegqwtAkUki8S5G0rvEcrWgVUpayV5Qd7Viee5QSSn7nyKD/PPy3crlfFRD5Yupm9sASqt+YOijng7X93Oe4MAbS8SN" >> /home/opencti/.ssh/authorized_keys'  opencti


#Upgrade
apt update
apt-get -y dist-upgrade
apt install -y openvpn openssl

timedatectl set-timezone 'America/Sao_Paulo'
dpkg-reconfigure --frontend noninteractive tzdata

cat > /etc/openvpn/service.conf <<EOF

dev tun
persist-tun
persist-key
cipher AES-128-CBC
tun-mtu 9000
auth SHA256
tls-client
client
resolv-retry infinite
remote honeypotmanager.opencti.net.br 45782 tcp
verify-x509-name "VPN_HoneyPOT" name
remote-cert-tls server
passtos

<ca>
-----BEGIN CERTIFICATE-----
MIIDIzCCAgugAwIBAgIBADANBgkqhkiG9w0BAQsFADAWMRQwEgYDVQQDEwtpbnRl
cm5hbC1jYTAeFw0yMDEwMTcwMzM0NTZaFw0zMDEwMTUwMzM0NTZaMBYxFDASBgNV
BAMTC2ludGVybmFsLWNhMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA
15vczkDlutFOdGLYwRRF5gHJybxx1eLYvn9ZPvAZgFjWevTr7NdJ6XoyxcMGk/+E
ODjnqS7o+Gr8VfE8dykMU63LHM5GQJ6zGX3Vdhic8dqLPh7i3hFEZIClib1Uvmc9
Z2oslLn8gnvM0gFfBg5kO9XMUiRVZRl1ZyugWCMwK6U2SM47Tdo6ZsFgQAAF/33X
PCcOcPr+50JfEzS+JNCyc13rkOayMzVnR7T+AcvrLG1mVmgPxM4de1NB4t+vLUUO
jvhh3VZBG738zVuOqVkpVlRYugLibcoRr5dVWvWdIyhwCstXuZHlkBhTPbcnOCUO
hDwf0xBVVScqXxYbB6Z3LQIDAQABo3wwejAdBgNVHQ4EFgQUnITJdxwtrC6nTA1s
MvOn7ezxU8EwPgYDVR0jBDcwNYAUnITJdxwtrC6nTA1sMvOn7ezxU8GhGqQYMBYx
FDASBgNVBAMTC2ludGVybmFsLWNhggEAMAwGA1UdEwQFMAMBAf8wCwYDVR0PBAQD
AgEGMA0GCSqGSIb3DQEBCwUAA4IBAQAf92IflkYzjDvS7CyTJqGmO9T0rVOi+9L+
E8DoGOSXJlfyzGKiXJMOAzy6u3QEAoZooBwjEunWzoqfgUPnx4vEXKLtcRtgoAMY
R9W2fovSPLjXHMeyIBoqLfuoDTfNaTNQAdQmbbomk81XPqQd3gKtPFTin3UyoGOM
kTLxEDMCqykVHrbduyXTSvDV1I7QzqhGdMy1pKMh052cp9ggEmYnmSJa3498E18p
HmEvHq9KJ7dn2e/kIjdFSK+PMFB0lyBHoExbeT7syxKoA92n/eVI14QHDmC7Macw
3LRV4WISCVbhXOEAvNe1cRHqLgJuVLf7xP48GL/sZyQ9MPQSRSHT
-----END CERTIFICATE-----
</ca>
<cert>
-----BEGIN CERTIFICATE-----
MIIDfDCCAmSgAwIBAgIBAjANBgkqhkiG9w0BAQsFADAWMRQwEgYDVQQDEwtpbnRl
cm5hbC1jYTAeFw0yMDEwMTcwMzQwNTdaFw0zMDEwMTUwMzQwNTdaMBMxETAPBgNV
BAMTCG1obkhvbmV5MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAsElo
PFJyeUr7aJ599pWKt4lO45ZrmhLFWUYY3vA4PM8T1rRhRi8c1v/PLqiTClWnReYW
lxIgxJI/MlvgP7eF4/VtpXkXX3jH2DJ8Fi7pgdvxNSqkR+B3DpqGcvX60TPzQ1kO
kvQpC1yVvkTLEbNdcwYQ4BnQdhyJVqxTyhZCTycW9GQq/YpXP1j8I68A22+bviBU
BgWp8WIReOcUirw6XIznoRrIQw/P4LJ7oqML0Ckv6qjcSI4AaiGXTcSRjeymPL4I
vKwE/XWKNpa+HBeXaYu4q3xK9FaRpBnHjB/BipTYK/0TrE4cRRCH+BOuCvge6un0
ab8BtPOToq0so3OdfwIDAQABo4HXMIHUMAkGA1UdEwQCMAAwCwYDVR0PBAQDAgXg
MDEGCWCGSAGG+EIBDQQkFiJPcGVuU1NMIEdlbmVyYXRlZCBVc2VyIENlcnRpZmlj
YXRlMB0GA1UdDgQWBBSpKJvL92A2g49SoIdVdpHph1HrhjA+BgNVHSMENzA1gBSc
hMl3HC2sLqdMDWwy86ft7PFTwaEapBgwFjEUMBIGA1UEAxMLaW50ZXJuYWwtY2GC
AQAwEwYDVR0lBAwwCgYIKwYBBQUHAwIwEwYDVR0RBAwwCoIIbWhuSG9uZXkwDQYJ
KoZIhvcNAQELBQADggEBAEY+kVcczEMRsZjpkPEjxe/BYVPt9LZmQX7un03e+A3Y
77HInh3Fj/VE6bhzy30qvFUsZRrqcEb+cyAmt74aYgGGlt5C2hwh5CCI7j/iyIR5
4USWx5YVStU/vwKiyhwg3s9oZUtFHYQv+tS/6ggEDxb6COUporBkwn9EimgZiqQM
F/Yb0o2KzrXUFp2LgRlWczXLeldOPPLVBR9eR31twM3fhOWVAWr4KDp06/Hz5oUW
IOrBWLpHofAr6pGSx6ASiPH6yQkUdNlRudV/Kz1HyK80ru4OU4fB9ydv9PKz68SZ
g4JEwgIsk+33rrqtjXjqrBt9kMj00BljZwHThhN6jr0=
-----END CERTIFICATE-----
</cert>
<key>
-----BEGIN PRIVATE KEY-----
MIIEvQIBADANBgkqhkiG9w0BAQEFAASCBKcwggSjAgEAAoIBAQCwSWg8UnJ5Svto
nn32lYq3iU7jlmuaEsVZRhje8Dg8zxPWtGFGLxzW/88uqJMKVadF5haXEiDEkj8y
W+A/t4Xj9W2leRdfeMfYMnwWLumB2/E1KqRH4HcOmoZy9frRM/NDWQ6S9CkLXJW+
RMsRs11zBhDgGdB2HIlWrFPKFkJPJxb0ZCr9ilc/WPwjrwDbb5u+IFQGBanxYhF4
5xSKvDpcjOehGshDD8/gsnuiowvQKS/qqNxIjgBqIZdNxJGN7KY8vgi8rAT9dYo2
lr4cF5dpi7irfEr0VpGkGceMH8GKlNgr/ROsThxFEIf4E64K+B7q6fRpvwG085Oi
rSyjc51/AgMBAAECggEAOO0Lfuc01hwzgT4k+PqjV888LVwGlTNYjRKIt30k++X2
xw9qlgpiqr7ifXOsP9sW8Ahz5QbSlAeR5sYqbQjrcIhxhszKkmbjSdpLnbI6b1fB
1WRWtmsypwGZRwhNnT7EYEwi26uCkYutQ0rdtHKSS7F6w5MycOGYK+fsCscTVJGG
saODuYdczMEyNee2vmuCxy614pt63kAODulptUhAUORB9BdvnD0PKg2j7puChO1M
Eu7pjM39q8ofELf37XyyrOudi1IDaq0LXNcnyoYeuMhOuUo8YJKcf9tLRLwT4L/1
diV+88nZVTqG5qkqQonyF2nE+tPIsEeviicMXgzkqQKBgQDUkl/TfUH9C/TraFcj
L9Si44L9JXx2p2vI9tf0FMP9IpN9g6j6cDJkCEZ2jqzoQb7gtjJhK1rUOEdRr/rU
/Us7QLshNCmU+BnuZbm9H5EsaOz0igLlV3PhDXSmYwQP4r1USA6DC5fAY06PhIPc
drAJt3pEX2wadFbuPrzS3Dsk7QKBgQDUTU4aNQpzPT/ouiie8qtx+xNv/3NMvk7T
lTbhekOz2AVz1iFm0CjHMos6rMjMoxcugUzsXZ6oOUIcW1pqfwjXe7k7CWdqwCXQ
jvFXuQoP53uuDzJeq/U+vem9ZlMmPp2bNhen5e5v7MqeNWijh/b6zUUs7ip1TUKp
aI16oZ8KmwKBgQDBj7eqQHiCDw0p/oy6AafB2yE/mY7IDJNdH0htfSspqP5cYDLS
OK/p3o8rDafspVFGFSGy0WOXstdeTrw8jZifj8XV6kWi3HfgWMjUqZXrtm9uDO2u
H//ogfQiPi9It9JmmGZ+dWPtT4ANt0DK01hgwK2Y7LrnK+CseHxAFUHV0QKBgEQA
fwPl+XLwK4hgGKLRGBlqUs+NA2GRk64yHWIbx5PTnet8qzZDdsxXZEFnFup1UveS
cxFC6472yDZNDKkQB8T93FcMrBOFeJdVMfjnTFHL09HtDDVG30c5jaUdIYUeiV0t
9mXRQI6ZSk1iziGTa4jqNz4tC2yHUtLwqmCdZFQBAoGAEXvVh2ETl2ireLUrkSK1
zVgNuVqLlay10GEpIZmXTyptcjs3vGTMqwY3UaWgNy+fJdx/ls8I994NeuwXsu7S
I+pRFEvNqLKJIGekPXAeesOGc2N1KMOyMsdX3GkYcLCRKCFm44Xw2jR5nBNVSalO
vCzzaQ0RJEXCVUI4ciLyT90=
-----END PRIVATE KEY-----
</key>
key-direction 1
<tls-auth>
#
# 2048 bit OpenVPN static key
#
-----BEGIN OpenVPN Static key V1-----
fc86233c66e6c392d6f3fdb57e43a8ab
ce3d4831bf540f8bd7029f207d88f329
7b693ea74c8500987071f8e6d616195d
8f365a81707ccf22d08bf5da0f7bd18e
d3fabb917cfb48c070beaa84803accb5
2ee439a18018f47d30b8322e3b6d4721
527bd5ca68509447ae5d869979dab9c8
0deefb2efdef9a2092989297c19b4186
4a9f22cfdd2227a544b8ac7a857819ed
1eadfd3c64cf01c903a7d65216b79f41
4fb4798cfb7a407d14aeb3901b380be4
91ecb7a5cf30e255e702d5cbe197f8aa
a8ec83e6384533407d306a37c8341c96
e825cc0a13d0ad678bee5546684f5829
1639e44cf96f1f572a8d38e8245568c6
278e7e4438cbf89804092adc473460c8
-----END OpenVPN Static key V1-----
</tls-auth>
EOF

systemctl enable openvpn@service
systemctl start openvpn@service

mkdir dionea
cd dionea


###################################################
# Instalacao Honeypot DIONEA - Projeto Opencti.BR #
# honeypot@opencti.net.br                         #
###################################################


server_url=http://172.28.144.1
deploy_key=h9fsOgOV


git clone https://github.com/DinoTools/dionaea.git 
cd dionaea

# Latest tested version with this install script
git checkout baf25d6

mkdir build
cd build
cmake -DCMAKE_INSTALL_PREFIX:PATH=/opt/dionaea ..

make
make install

wget $server_url/static/registration.txt -O registration.sh
chmod 755 registration.sh
# Note: this will export the HPF_* variables
. ./registration.sh $server_url $deploy_key "dionaea"

cat > /opt/dionaea/etc/dionaea/ihandlers-enabled/hpfeeds.yaml <<EOF
- name: hpfeeds
  config:
    # fqdn/ip and port of the hpfeeds broker
    server: "$HPF_HOST"
    # port: $HPF_PORT
    ident: "$HPF_IDENT"
    secret: "$HPF_SECRET"
    # dynip_resolve: enable to lookup the sensor ip through a webservice
    dynip_resolve: "http://canhazip.com/"
    # Try to reconnect after N seconds if disconnected from hpfeeds broker
    # reconnect_timeout: 10.0
EOF


# Editing configuration for Dionaea.
mkdir -p /opt/dionaea/var/log/dionaea/wwwroot /opt/dionaea/var/log/dionaea/binaries /opt/dionaea/var/log/dionaea/log
chown -R nobody:nogroup /opt/dionaea/var/log/dionaea

mkdir -p /opt/dionaea/var/log/dionaea/bistreams 
chown nobody:nogroup /opt/dionaea/var/log/dionaea/bistreams

# Config for supervisor.
cat > /etc/supervisor/conf.d/dionaea.conf <<EOF
[program:dionaea]
command=/opt/dionaea/bin/dionaea -c /opt/dionaea/etc/dionaea/dionaea.cfg
directory=/opt/dionaea/
stdout_logfile=/opt/dionaea/var/log/dionaea.out
stderr_logfile=/opt/dionaea/var/log/dionaea.err
autostart=true
autorestart=true
redirect_stderr=true
stopsignal=QUIT
EOF

supervisorctl update

cd /etc/logrotate.d/
cat > dionaea << EOF
#!/bin/bash
if [ -s "/opt/dionaea/var/log/dionaea/dionaea.log" ]
then

rm /opt/dionaea/var/log/dionaea/dionaea.log
rm /opt/dionaea/var/log/dionaea/dionaea-errors.log
supervisorctl restart all

else
         echo "Your file is empty"
fi
EOF

echo "00 23   * * *   root 	/etc/logrotate.d/dionaea" >> /etc/crontab

chmod 755 /etc/logrotate.d/dionaea


# Config for supervisor.
cat > /opt/dionaea/etc/dionaea/services-enabled/blackhole.yaml <<EOF
- name: blackhole
  config:
    services:
      # Telnet
      - port: 23
        protocol: tcp

      # DNS
      - port: 53
        protocol: udp
      - port: 53
        protocol: tcp

      # NTP
      - port: 123
        protocol: udp

      # LDAP
      - port: 389
        protocol: tcp

      # http-proxy
      - port: 8080
        protocol: tcp

      # https
      - port: 8443
        protocol: tcp

      # proxy
      - port: 3128
        protocol: tcp

      # ISAKMP
      - port: 500
        protocol: tcp
	
      # ISAKMP
      - port: 500
        protocol: udp

      # OpenVPN
      - port: 1194
        protocol: tcp
      
      # OpenVPN
      - port: 1194
        protocol: udp
      
      # mDNS
      - port: 5353
        protocol: udp

      # mDNS
      - port: 5353
        protocol: tcp
	
      # msrpc
      - port: 135
        protocol: tcp
	
      # netbios-ssn
      - port: 139
        protocol: tcp
EOF




cd ..
_result=$(cat /etc/passwd| grep cowrie | wc -l)
if [ $_result -ne 0 ]
then
	userdel -r cowrie
fi
rm -rf cowrie
mkdir cowrie
cd cowrie


###################################################
# Instalacao Honeypot COWRIE - Projeto Opencti.BR #
# honeypot@opencti.net.br                         #
###################################################




server_url=http://172.28.144.1
deploy_key=h9fsOgOV

/etc/init.d/supervisor start || true

useradd -d /home/cowrie -s /bin/bash -m cowrie -g users

cd /opt
# git clone https://github.com/micheloosterhof/cowrie.git cowrie
# cd cowrie
wget https://github.com/cowrie/cowrie/archive/refs/tags/v2.5.0.zip
unzip v2.5.0.zip
mv cowrie-2.5.0 cowrie
cd cowrie

# Most recent known working version
# git checkout 34f8464

# Config for requirements.txt
cat > /opt/cowrie/requirements.txt <<EOF
twisted>=17.1.0
cryptography>=2.1
configparser
pyopenssl
pyparsing
packaging
appdirs>=1.4.0
pyasn1_modules
attrs
service_identity
python-dateutil
tftpy
bcrypt
EOF


virtualenv cowrie-env #env name has changed to cowrie-env on latest version of cowrie
source cowrie-env/bin/activate
# without the following, i get this error:
# Could not find a version that satisfies the requirement csirtgsdk (from -r requirements.txt (line 10)) (from versions: 0.0.0a5, 0.0.0a6, 0.0.0a5.linux-x86_64, 0.0.0a6.linux-x86_64, 0.0.0a3)

python -m pip install "setuptools<45"
pip2 install pip==19.2.3
pip2 install -U setuptools wheel
easy_install-2.7 distribute
pip2 install --upgrade distribute
pip2 install csirtgsdk==0.0.0a6
pip2 install -r requirements.txt 

# Register sensor with MHN server.
wget $server_url/static/registration.txt -O registration.sh
chmod 755 registration.sh
# Note: this will export the HPF_* variables
. ./registration.sh $server_url $deploy_key "cowrie"

cd etc
cp cowrie.cfg.dist cowrie.cfg
sed -i 's/hostname = svr04/hostname = server/g' cowrie.cfg
sed -i 's/listen_endpoints = tcp:2222:interface=0.0.0.0/listen_endpoints = tcp:22:interface=0.0.0.0/g' cowrie.cfg
sed -i 's/version = SSH-2.0-OpenSSH_6.0p1 Debian-4+deb7u2/version = SSH-2.0-OpenSSH_6.7p1 Ubuntu-5ubuntu1.3/g' cowrie.cfg
sed -i 's/#\[output_hpfeeds\]/[output_hpfeeds]/g' cowrie.cfg
sed -i '/\[output_hpfeeds\]/!b;n;cenabled = true' cowrie.cfg
sed -i "s/#server = hpfeeds.mysite.org/server = $HPF_HOST/g" cowrie.cfg
sed -i "s/#port = 10000/port = $HPF_PORT/g" cowrie.cfg
sed -i "s/#identifier = abc123/identifier = $HPF_IDENT/g" cowrie.cfg
sed -i "s/#secret = secret/secret = $HPF_SECRET/g" cowrie.cfg
sed -i 's/#debug=false/debug=false/' cowrie.cfg
cd ..

chown -R cowrie:users /opt/cowrie/
touch /etc/authbind/byport/22
chown cowrie /etc/authbind/byport/22
chmod 770 /etc/authbind/byport/22

# start.sh is deprecated on new Cowrie version and substituted by "bin/cowrie [start/stop/status]"
sed -i 's/AUTHBIND_ENABLED=no/AUTHBIND_ENABLED=yes/' bin/cowrie
sed -i 's/DAEMONIZE=""/DAEMONIZE="-n"/' bin/cowrie

# Config for supervisor
cat > /etc/supervisor/conf.d/cowrie.conf <<EOF
[program:cowrie]
command=/opt/cowrie/bin/cowrie start
directory=/opt/cowrie
stdout_logfile=/opt/cowrie/var/log/cowrie/cowrie.out
stderr_logfile=/opt/cowrie/var/log/cowrie/cowrie.err
autostart=true
autorestart=true
stopasgroup=true
killasgroup=true
user=cowrie
EOF

supervisorctl update

cd ..


mkdir elastic
cd elastic
##########################################################
# Instalacao Honeypot ElasticSearch - Projeto Opencti.BR #
# honeypot@opencti.net.br                                #
##########################################################


server_url=http://172.28.144.1
deploy_key=h9fsOgOV

apt-get update
apt-get -y install git golang supervisor


# Get the elastichoney source
cd /opt
git clone https://github.com/pwnlandia/elastichoney.git
cd elastichoney

export GOPATH=/opt/elastichoney
go get || true
go build

# Register the sensor with the MHN server.
wget $server_url/static/registration.txt -O registration.sh
chmod 755 registration.sh
# Note: this will export the HPF_* variables
. ./registration.sh $server_url $deploy_key "elastichoney"

cat > config.json<<EOF
{
    "logfile" : "/opt/elastichoney/elastichoney.log",
    "use_remote" : false,
    "remote" : {
        "url" : "http://example.com",
        "use_auth" : false,
        "auth" : {
            "username" : "",
            "password" : ""
        }
    },
    "hpfeeds": {
        "enabled": true,
        "host": "$HPF_HOST",
        "port": $HPF_PORT,
        "ident": "$HPF_IDENT",
        "secret": "$HPF_SECRET",
        "channel": "elastichoney.events"
    },
    "instance_name" : "Green Goblin",
    "anonymous" : false,
    "spoofed_version"  : "1.4.1",
    "public_ip_url": "http://icanhazip.com"
}
EOF

# Config for supervisor.
cat > /etc/supervisor/conf.d/elastichoney.conf <<EOF
[program:elastichoney]
command=/opt/elastichoney/elastichoney
directory=/opt/elastichoney
stdout_logfile=/opt/elastichoney/elastichoney.out
stderr_logfile=/opt/elastichoney/elastichoney.err
autostart=true
autorestart=true
redirect_stderr=true
stopsignal=QUIT
EOF

supervisorctl update
cd ..

mkdir amun
cd amun

##########################################################
# Instalacao Honeypot Amun - Projeto Opencti.BR #
# honeypot@opencti.net.br                                #
##########################################################


server_url=http://172.28.144.1
deploy_key=h9fsOgOV

apt-get update
apt-get -y install git python-pip supervisor

# Get the Amun source
cd /opt
git clone https://github.com/zeroq/amun.git
cd amun
AMUN_HOME=/opt/amun 

# Configure Amun (disable vuln-http, too many false alarms here)
sed -i 's/ip: 127.0.0.1/ip: 0.0.0.0/g' conf/amun.conf
sed -i 's/    vuln-http,/#   vuln-http,/g' conf/amun.conf
sed -i 's/\tvuln-http\,/#       vuln-http\,/g' /opt/amun/conf/amun.conf
sed -i 's/\tvuln-smb\,/#       vuln-smb\,/g' /opt/amun/conf/amun.conf
sed -i 's/\tvuln-ftpd\,/#       vuln-ftpd\,/g' /opt/amun/conf/amun.conf
sed -i 's/#vuln-realvnc\:/vuln-realvnc\:/g' /opt/amun/conf/amun.conf
sed -i 's/\tvuln-iis\,/#\tvuln-iis/g' /opt/amun/conf/amun.conf
sed -i 's/vuln-check\:/#vuln-check\:/g' /opt/amun/conf/amun.conf
sed -i 's/\tvuln-check\,/#\tvuln-check/g' /opt/amun/conf/amun.conf
sed -i 's/\tvuln-dcom\,/#\tvuln-dcom/g' /opt/amun/conf/amun.conf
sed -i 's/\tvuln-wins\,/#\tvuln-wins/g' /opt/amun/conf/amun.conf
sed -i 's/vuln-msmq\,/vuln-msmq\,\n\tvuln-realvnc\,/g' /opt/amun/conf/amun.conf
sed -i $'s/log_modules:/log_modules:\\\n    log-hpfeeds/g' conf/amun.conf

# Modify Ubuntu to accept more open files
echo "104854" > /proc/sys/fs/file-max
ulimit -Hn 104854
ulimit -n 104854

# Register the sensor with the MHN server.
wget $server_url/static/registration.txt -O registration.sh
chmod 755 registration.sh
# Note: this will export the HPF_* variables
. ./registration.sh $server_url $deploy_key "amun"

# Setup HPFeeds
cat > /opt/amun/conf/log-hpfeeds.conf <<EOF

[database_hpfeeds]
server = $HPF_HOST
port = $HPF_PORT
identifier = $HPF_IDENT
secret = $HPF_SECRET
debug = 0

EOF


# Config for supervisor.
cat > /etc/supervisor/conf.d/amun.conf <<EOF
[program:amun]
command=$AMUN_HOME/amun_server.py 
directory=/opt/amun
stdout_logfile=/opt/amun/amun.out
stderr_logfile=/opt/amun/amun.err
autostart=true
autorestart=true
redirect_stderr=true
stopsignal=QUIT
EOF

supervisorctl update

cd ..

mkdir suricata
cd suricata

##########################################################
# Instalacao Honeypot Suricata      - Projeto Opencti.BR #
# honeypot@opencti.net.br                                #
##########################################################

server_url=http://172.28.144.1
deploy_key=h9fsOgOV

INTERFACE=$(basename -a /sys/class/net/e*)

set -e
set -x

compareint=$(echo "$INTERFACE" | wc -w)


if [ "$INTERFACE" = "e*" ] || [ "$compareint" -ne 1 ]
    then
        echo "No Interface selectable, please provide manually."
        echo "Usage: $0 <server_url> <deploy_key> <INTERFACE>"
        exit 1
fi

apt-get update
DEBIAN_FRONTEND=noninteractive apt-get -y install build-essential libpcap-dev libjansson-dev libpcre3-dev libdnet-dev libdumbnet-dev libdaq-dev flex bison python-pip git make automake libtool zlib1g-dev python-dev libnetfilter-queue-dev libnetfilter-queue1 libnfnetlink-dev libnfnetlink0 libyaml-dev libmagic-dev autoconf libpcre3 libpcre3-dbg libnet1-dev libyaml-0-2 pkg-config zlib1g libcap-ng-dev libcap-ng0

pip install --upgrade distribute
pip install pyyaml

# Install hpfeeds and required libs...

cd /tmp
rm -rf libev*
wget https://github.com/pwnlandia/hpfeeds/releases/download/libev-4.15/libev-4.15.tar.gz
tar zxvf libev-4.15.tar.gz 
cd libev-4.15
./configure && make && make install
ldconfig

cd /tmp
rm -rf hpfeeds
git clone https://github.com/pwnlandia/hpfeeds.git
cd hpfeeds/appsupport/libhpfeeds
autoreconf --install
./configure && make && make install 
ldconfig

cd /tmp
rm -rf htp*
wget https://github.com/ironbee/libhtp/releases/download/0.5.15/htp-0.5.15.tar.gz
tar -xzvf htp-0.5.15.tar.gz
cd htp-0.5.15
./configure && make && make install
ldconfig

mkdir -p /opt/suricata/etc/suricata/rules /opt/mhn/rules/

cd /tmp
rm -rf suricata
git clone -b hpfeeds-support https://github.com/threatstream/suricata.git
cd suricata
./autogen.sh || ./autogen.sh
export CPPFLAGS=-I/include
./configure --prefix=/opt/suricata --localstatedir=/var/ --enable-non-bundled-htp 
make
make install-conf
make install

# Register the sensor with MHN server.
wget $server_url/static/registration.txt -O registration.sh
chmod 755 registration.sh
# Note: this will export the HPF_* variables
. ./registration.sh $server_url $deploy_key "suricata"
 
cd /opt/suricata/etc/suricata
#sed -i -r "/\s*- alert-hpfeeds/,/\s*reconnect: yes # do we reconnect if publish fails/d" suricata.yaml
#sed -i -r "s/^  # hpfeeds output/ # hpfeeds output\n  - alert-hpfeeds:\n      enabled: yes\n      host: $HPF_HOST\n      ident: $HPF_IDENT\n      secret: $HPF_SECRET\n      channel: suricata.events\n      reconnect: yes # do we reconnect if publish fails ?!\n/" suricata.yaml

# replace the faulty magic file
COMMAND="s#magic-file: /usr/share/file/misc/magic#magic-file: /usr/share/file/magic#;"

# delete the example hpfeeds config section
COMMAND+="/  - alert-hpfeeds/,/      reconnect: yes # do we reconnect if publish fails/d;"

# replace the hpfeeds section with the vaues from the env vars
COMMAND+="s/^  # hpfeeds output/"
COMMAND+="  # hpfeeds output\n"
COMMAND+="  - alert-hpfeeds:\n"
COMMAND+="      enabled: yes\n"
COMMAND+="      host: $HPF_HOST\n"
COMMAND+="      port: $HPF_PORT\n"
COMMAND+="      ident: $HPF_IDENT\n"
COMMAND+="      secret: $HPF_SECRET\n"
COMMAND+="      channel: suricata.events\n"
COMMAND+="      reconnect: yes # do we reconnect if publish fails ?!\n/;"

# disable all the rules then enable just the local.rules
COMMAND+="s/^( - .*\.rules)/#\1/;  s/rule-files:/rule-files:\n - local.rules/"

sed -i -r "$COMMAND" suricata.yaml

IP=$(ip -f inet -o addr show $INTERFACE|head -n 1|cut -d\  -f 7 | cut -d/ -f 1)
sed -i "s#    HOME_NET: \"\[192.168.0.0/16,10.0.0.0/8,172.16.0.0/12\]\"#    HOME_NET: \"[$IP]\"#" suricata.yaml

# Installing snort rules.
# mhn.rules will be used as local.rules.
rm -f /opt/suricata/etc/suricata/rules/local.rules
ln -s /opt/mhn/rules/mhn-suricata.rules /opt/suricata/etc/suricata/rules/local.rules

sed -i s/local\.rules/local\.rules\\n\ -\ snort\.rules/g  /opt/suricata/etc/suricata/suricata.yaml
sed -i s/local\.rules/local\.rules\\n\ -\ opencti\.rules/g  /opt/suricata/etc/suricata/suricata.yaml
touch /opt/suricata/etc/suricata/rules/snort.rules
touch /opt/suricata/etc/suricata/rules/opencti.rules

apt-get install -y supervisor

# Config for supervisor.
cat > /etc/supervisor/conf.d/suricata.conf <<EOF
[program:suricata]
command=/opt/suricata/bin/suricata -c /opt/suricata/etc/suricata/suricata.yaml -i $INTERFACE
directory=/opt/suricata
stdout_logfile=/var/log/suricata.log
stderr_logfile=/var/log/suricata.err
autostart=true
autorestart=true
redirect_stderr=true
stopsignal=QUIT
EOF

cat > /etc/cron.daily/update_suricata_rules.sh <<EOF
#!/bin/bash

mkdir -p /opt/mhn/rules
rm -f /opt/mhn/rules/mhn.rules.tmp

echo "[`date`] Updating suricata signatures ..."
wget $server_url/static/mhn.rules -O /opt/mhn/rules/mhn-suricata.rules.tmp && \
	mv /opt/mhn/rules/mhn-suricata.rules.tmp /opt/mhn/rules/mhn-suricata.rules && \
	(supervisorctl update ; supervisorctl restart suricata ) && \
	echo "[`date`] Successfully updated suricata signatures" && \
	exit 0

echo "[`date`] Failed to update suricata signatures"
exit 1
EOF
chmod 755 /etc/cron.daily/update_suricata_rules.sh
/etc/cron.daily/update_suricata_rules.sh

supervisorctl update

