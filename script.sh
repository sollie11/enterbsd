#!/bin/sh
mkdir -p /data/disk/mkiso/install
ln -s /data/disk/mkiso/ /1
cd /1/install

cat << EOF > 00clear
#!/bin/sh
echo "Deleting"
cd /1
if [ -d cd1 ]; then
 cd cd1
 chflags -R noschg *
 cd ..
fi;
rm -rf cd1
rm -rf ramdisk
rm -rf cd
rm *.iso
rm mkiso/*.iso

EOF


cat << EOF > 01create 
#!/bin/sh
mkdir /1/cd1
mkdir -p /1/cd/install /1/cd/boot /1/ramdisk/rescue /1/boot
cd /1/install/
cp * /1/cd/install
if [ ! -f /1/00clear ]; then
 cp /1/cd/install/0* /1
fi
mkdir /1/cd/boot 
cd /mnt
cd cdrom
cd boot 
tar --exclude='kernel' -pcf - . | ( cd /1/cd/boot/ && tar -pxf - )
cd /1/cd/boot
mkdir kernel && cd /mnt/cdrom/boot/kernel
cp kernel fdescfs.ko geom_uzip.ko if_tap.ko if_tun.ko nullfs.ko pf.ko pflog.ko pfsync.ko procfs.ko snd_ich.ko tmpfs.ko unionfs.ko /1/cd/boot/kernel
mkdir -p  /1/cd/data /1/cd/install /1/cd1
echo "RAMdisk ..."
mkdir -p /1/ramdisk/dev /1/ramdisk/etc /1/ramdisk/rescue
touch /1/ramdisk/etc/fstab
cd /1/ramdisk/rescue
cp /1/install/initboot /1/ramdisk
tar -pxf /1/install/9rescue.tar.gz
makefs -b 10% ramdisk.ufs /1/ramdisk
gzip ramdisk.ufs
rm /1/cd/data/ramdisk.ufs.gz
mv ramdisk.ufs.gz /1/cd/data
cd /1
rm -rf ramdisk

EOF


cat << EOF > 02clone 
#!/bin/sh
cd /1/cd1
echo "Cloning"
tar pcf - /bin | ( cd /1/cd1 && tar pxvf - )
mkdir -p /1/cd1/boot/kernel
cp /1/cd/boot/kernel/* /1/cd1/boot/kernel
mkdir -p /1/cd1/dev
mkdir -p /1/cd1/data
cd /1/cd1/data
#mkdir sql svn samba disk nfs www var
mkdir disk
cp /1/install/startup .
cd disk
#mkdir -p etc var usr/local/etc
#chown -R www:www /1/cd1/data/www
#ln -s /data/www /usr/local/www
#touch /1/cd1/data/www/notpop
#tar --exlude='www' --exclude='disk' --exclude='sql' --exclude='startup' --exclude='samba' --exclude='nfs' -pcf - /data | ( cd /1/cd1 && tar pxvf - )
#chmod -R 777 /1/cd1/data/samba
tar pcf - /etc | ( cd /1/cd1 && tar pxvf - )
tar pcf - /lib | ( cd /1/cd1 && tar pxvf - )
tar pcf - /libexec | ( cd /1/cd1 && tar pxvf - )
mkdir -p /1/cd1/media
mkdir -p /1/cd1/mnt
mkdir -p /1/cd1/proc
mkdir -p /1/cd1/root
cd /1/cd1/root
cp /root/.cshrc .
cp /root/.k5login .
cp /root/.login .
cp /root/.profile .
cd /1/
tar pcf - /sbin | ( cd /1/cd1 && tar pxvf - )
mkdir -p /1/cd1/tmp
chmod -R 1777 /1/cd1/tmp
tar --exclude='./run/ppp' --exclude='./cache/pkg' --exclude='./db/portsnap' --exclude='./db/clamav' --exclude='cache/pkg' --exclude='*.pid' --exclude='freebsd-update' -pcf - /var | ( cd /1/cd1 && tar -pxvf - )
mkdir /1/cd1/var/db/freebsd-update
mkdir /1/cd1/var/cache/pkg
#mkdir -p /1/cd1/usr/local/www/apache24/data
#mkdir -p /1/cd1/var/db/clamav
#mkdir -p /1/cd1/usr/local/share/tessdata
#mkdir -p /1/cd1/usr/local/etc/rc.d
tar --exclude='./local/share/tessdata' --exclude='pc-sysinstall' --exclude='games' --exclude='.git' --exclude='x86_64-portbld-freebsd11.0' --exclude='./ports' -pcf - /usr | ( cd /1/cd1 && tar -pxvf - )
ln -s /usr/home /1/cd1/home
cp /COPYRIGHT /1/cd1
cp /ENTERBSD /1/cd1

EOF


cat << EOF > 04etc 
#!/bin/sh
cd /1/install
cp * /1/cd/install/
mkdir -p /1/cd1/usr/local/bin
cp 8reboot /1/cd1/usr/local/bin/0reboot
cp 8shutdown /1/cd1/usr/local/bin/0shutdown
cp ENTERBSD /1/cd1/
cp all.log /1/cd1/var/log/
cp brand-fbsd.4th /1/cd/boot/
cp cdboot /1/cd1/boot/
cp console.log /1/cd1/var/log/
cp dhclient-enter-hooks /1/cd1/etc/
cp enter.logo /1/cd1/boot/
cp enter.rc.d /1/cd1/etc/rc.d/enter
cp enter.sbin /1/cd1/usr/sbin/enter
cp fstab.cd /1/cd1/etc/fstab
cp group /1/cd1/etc/
cp master.passwd /1/cd1/etc/
cp passwd /1/cd1/etc/
cp pwd.db /1/cd1/etc/
cp hosts /1/cd1/etc/
cp loader.conf.cd /1/cd/boot/loader.conf
cp logo-enter.4th /1/cd/boot/
cp motd /1/cd1/etc/
cp rc.conf.big /1/cd1/etc/rc.conf.big
cp rc.conf.small /1/cd1/etc/rc.conf
cp rc.conf.small /1/cd1/etc/rc.conf.small
cp resolv.conf /1/cd1/etc/
cp startup /1/cd1/data/
cp sysctl.conf /1/cd1/etc/
cp syslog.conf /1/cd1/etc/
cp /1/0* /1/cd/install/
cp /1/0* /1/install/
rm /1/cd/install/9boot.tar.gz

EOF



cat << EOF > 06mksys 
#!/bin/sh
echo "makefs system cd1 ..."
date
makefs system cd1
echo "mkuzip system ..."
date
mkuzip system
rm /1/cd/data/system.uzip
mv system.uzip /1/cd/data
rm system
date
du -h /1/cd

EOF


cat << EOF > 07mkcd 
#!/bin/sh
cd /1/cd
cp ../install/cdboot /1/cd/boot
mkisofs -R -l -ldots -allow-lowercase -allow-multidot -V 'Enter' -volset 'Enter' \
-hide boot.catalog -o ../EnterBSD-\$1.iso -no-emul-boot -b boot/cdboot .
#mv ../EnterBSD-\$1.iso /data/nfs

EOF


cat << EOF > 09hdboot
#!/bin/sh
echo "Copying filesystem to disk ..."
cp /COPYRIGHT /data
cp /ENTERBSD /data
mkdir /data/bin && cd /bin && tar cf - . | ( cd /data/bin/ && tar xBf - )
mkdir /data/boot && cd /boot && tar cf - . | ( cd /data/boot/ && tar xBf - )
mkdir /data/dev
mkdir /data/etc && cd /etc && tar cf - . | ( cd /data/etc/ && tar xBf - )
mkdir /data/lib && cd /lib && tar cf - . | ( cd /data/lib/ && tar xBf - )
mkdir /data/libexec && cd /libexec && tar cf - . | ( cd /data/libexec/ && tar xBf - )
mkdir /data/media
mkdir /data/mnt
mkdir /data/proc
mkdir /data/root && cd /root && tar cf - . | ( cd /data/root/ && tar xBf - )
mkdir /data/sbin && cd /sbin && tar cf - . | ( cd /data/sbin/ && tar xBf - )
mkdir /data/tmp && chmod -R 1777 /data/tmp
echo "Copying /usr ..."
mkdir /data/usr && cd /usr && tar cf - . | ( cd /data/usr/ && tar xBf - )
mkdir /data/var && cd /var && tar --exclude='.pid' --exclude='.pid' -pcf - . | ( cd /data/var/ && tar -pxf - )
mkdir /data/data
mkdir /data/data/disk && mv /data/disk /data/data/
rm -rf /data/disk/etc /data/disk/usr /data/disk/var
#mkdir /data/data/etc && mv /data/etc /data/data/etc
echo ""
echo "Configuring ..."
mv /data/startup /data/data/startup
#mkdir /data/data/var && mv /data/var /data/data/var
cd /data/data/disk/mkiso/install
cp fstab.hd /data/etc/fstab
cd /mnt
cd cdrom
cd boot
cp -pR * /data/boot/
cd /data/data/disk/mkiso/install/
cp loader.conf.hd /data/boot/loader.conf
echo "You may reboot from hard disk now."
echo "Press Ctrl-C to abort reboot ..."
read xkey
0reboot

EOF


cat << EOF > 8reboot 
#!/bin/sh
cp /etc/rc.conf.small /etc/rc.conf
shutdown -r now

EOF


cat << EOF > 8shutdown 
#!/bin/sh
cp /etc/rc.conf.small /etc/rc.conf
shutdown -p now

EOF



#############################################
cat <<EOFB > 7xfce
#!/bin/sh
pkg install -y xorg xfce lightdm-gtk-greeter xfce4-whiskermenu-plugin xfce4-cpugraph-plugin xfce4-netload-plugin xfce4-diskperf-plugin xfce4-screenshooter-plugin xfce4-dict-plugin xfce4-volumed xfce4-taskmanager

cat << EOF >> /etc/rc.conf

lightdm_enable="YES"
dbus_enable="YES"
hald_enable="YES"

EOF

service hald start
service dbus start

mkdir -p /usr/local/share/themes/0EnterBSD/gtk-2.0
cd /usr/local/share/themes/0EnterBSD
mkdir xfwm4
cd xfwm4


EOFB

#############################################
cat << EOFB > 7amp
#!/bin/sh
pkg install -y mariadb102-server apache24 mod_php71 mod_dav_svn cronolog php71-bcmath php71-bz2 php71-calendar php71-curl php71-exif php71-fileinfo php71-filter php71-gd php71-gettext php71-json php71-hash php71-mbstring php71-mcrypt php71-mysqli php71-opcache php71-openssl php71-pdo_mysql php71-phar php71-posix php71-soap php71-sockets php71-wddx php71-zip php71-zlib

cat << EOF > /var/db/mysql/my.cnf
[client]
port = 3306
default-character-set = utf8
[mysqld]
character-set-server = utf8
port = 3306
skip-name-resolve
default-storage-engine = InnoDB
skip-external-locking
key_buffer_size = 16M
max_allowed_packet = 10M
table_open_cache = 64
sort_buffer_size = 512K
net_buffer_length = 8K
read_buffer_size = 256K
read_rnd_buffer_size = 512K
myisam_sort_buffer_size = 8M
log-bin=mysql-bin
binlog_format=mixed
server-id = 1
innodb_data_home_dir = /data/sql
innodb_data_file_path = ibdata1:10M:autoextend
innodb_log_group_home_dir = /data/sql
innodb_buffer_pool_size = 16M
innodb_log_file_size = 5M
innodb_log_buffer_size = 8M
innodb_flush_log_at_trx_commit = 1
innodb_lock_wait_timeout = 50
[mysqldump]
quick
max_allowed_packet = 16M
[mysql]
no-auto-rehash
[myisamchk]
key_buffer_size = 20M
sort_buffer_size = 20M
read_buffer = 2M
write_buffer = 2M
[mysqlhotcopy]
interactive-timeout
EOF


cd /usr/local/etc/rc.d/
sed -e "s/\var\/db\/mysql/data\/sql/g" mysql-server > ms
chmod +x ms
mv ms mysql-server



mv /usr/local/etc/apache24/httpd.conf /usr/local/etc/apache24/httpd.conf.old
cat << EOF > /usr/local/etc/apache24/httpd.conf
LoadFile /usr/local/lib/libxml2.so
LoadModule mpm_prefork_module libexec/apache24/mod_mpm_prefork.so
LoadModule unixd_module libexec/apache24/mod_unixd.so
LoadModule proxy_module libexec/apache24/mod_proxy.so
LoadModule proxy_http_module libexec/apache24/mod_proxy_http.so
LoadModule authn_file_module libexec/apache24/mod_authn_file.so
LoadModule authn_dbm_module libexec/apache24/mod_authn_dbm.so
LoadModule authn_anon_module libexec/apache24/mod_authn_anon.so
LoadModule authz_core_module libexec/apache24/mod_authz_core.so
LoadModule authz_host_module libexec/apache24/mod_authz_host.so
LoadModule authz_groupfile_module libexec/apache24/mod_authz_groupfile.so
LoadModule authz_user_module libexec/apache24/mod_authz_user.so
LoadModule authz_dbm_module libexec/apache24/mod_authz_dbm.so
LoadModule authz_owner_module libexec/apache24/mod_authz_owner.so
LoadModule authn_core_module libexec/apache24/mod_authn_core.so
LoadModule auth_basic_module libexec/apache24/mod_auth_basic.so
LoadModule auth_digest_module libexec/apache24/mod_auth_digest.so
LoadModule file_cache_module libexec/apache24/mod_file_cache.so
LoadModule cache_module libexec/apache24/mod_cache.so
LoadModule dumpio_module libexec/apache24/mod_dumpio.so
LoadModule reqtimeout_module libexec/apache24/mod_reqtimeout.so
LoadModule include_module libexec/apache24/mod_include.so
LoadModule filter_module libexec/apache24/mod_filter.so
LoadModule deflate_module libexec/apache24/mod_deflate.so
LoadModule log_config_module libexec/apache24/mod_log_config.so
LoadModule logio_module libexec/apache24/mod_logio.so
LoadModule env_module libexec/apache24/mod_env.so
LoadModule mime_magic_module libexec/apache24/mod_mime_magic.so
LoadModule cern_meta_module libexec/apache24/mod_cern_meta.so
LoadModule expires_module libexec/apache24/mod_expires.so
LoadModule headers_module libexec/apache24/mod_headers.so
LoadModule unique_id_module libexec/apache24/mod_unique_id.so
LoadModule setenvif_module libexec/apache24/mod_setenvif.so
LoadModule version_module libexec/apache24/mod_version.so
LoadModule ssl_module libexec/apache24/mod_ssl.so
LoadModule mime_module libexec/apache24/mod_mime.so
LoadModule status_module libexec/apache24/mod_status.so
LoadModule autoindex_module libexec/apache24/mod_autoindex.so
LoadModule asis_module libexec/apache24/mod_asis.so
LoadModule info_module libexec/apache24/mod_info.so
LoadModule cgi_module libexec/apache24/mod_cgi.so
LoadModule vhost_alias_module libexec/apache24/mod_vhost_alias.so
LoadModule negotiation_module libexec/apache24/mod_negotiation.so
LoadModule dir_module libexec/apache24/mod_dir.so
LoadModule imagemap_module libexec/apache24/mod_imagemap.so
LoadModule actions_module libexec/apache24/mod_actions.so
LoadModule speling_module libexec/apache24/mod_speling.so
LoadModule userdir_module libexec/apache24/mod_userdir.so
LoadModule alias_module libexec/apache24/mod_alias.so
LoadModule rewrite_module libexec/apache24/mod_rewrite.so
LoadModule dav_module libexec/apache24/mod_dav.so
LoadModule dav_fs_module libexec/apache24/mod_dav_fs.so
LoadModule dav_svn_module libexec/apache24/mod_dav_svn.so
LoadModule access_compat_module libexec/apache24/mod_access_compat.so
LoadModule authz_svn_module libexec/apache24/mod_authz_svn.so
LoadModule php7_module libexec/apache24/libphp7.so
LoadModule socache_shmcb_module libexec/apache24/mod_socache_shmcb.so
ServerRoot "/usr/local"
Listen 80
ServerAdmin support@localhost
ServerName localhost:80
DocumentRoot "/usr/local/www/apache24/data"
AddDefaultCharset UTF-8
Header always set Strict-Transport-Security "max-age=500; includeSubDomains"
Header set Access-Control-Allow-Origin "*"
ExpiresActive on
ExpiresByType image/png "acces plus 1 month"
LogFormat "%h %l %u %t \"%r\" %>s %b \"%{Referer}i\" \"%{User-Agent}i\""
TransferLog "|/usr/local/sbin/cronolog /var/log/web/%Y/%m/%d_access.log"
ErrorLog "|/usr/local/sbin/cronolog /var/log/web/%Y/%m/%d_error.log"
LogLevel warn
ErrorDocument 403 /
ErrorDocument 404 /
User www
Group www
<IfModule !mpm_netware_module>
 <IfModule !mpm_winnt_module>
 </IfModule>
</IfModule>
<Directory />
 AllowOverride None
 Require all denied
</Directory>
<Directory "/usr/local/www/apache24/data">
 RewriteEngine on
 AllowOverride All
 Require all granted
 Options -Indexes
# RewriteCond %{SERVER_PORT} !^443\$
# RewriteRule ^.*\$ https://%{SERVER_NAME}%{REQUEST_URI} [L,R]
 SetEnvIfNoCase Referer "impi.net" local_ref=1
 SetEnvIf Request_URI "\.ico\$" local_ref=1
 SetEnvIf Request_URI "\.apk\$" local_ref=1
 SetEnvIf Request_URI "\.sisx\$" local_ref=1
 SetEnvIf Request_URI "\.jad\$" local_ref=1
 SetEnvIf Request_URI "\.ttf\$" local_ref=1
 <FilesMatch ".(gif|jpg|jpeg|png|swf|mpg|avi|flv|ttf)">
 </FilesMatch>
</Directory>
<IfModule dir_module>
 DirectoryIndex index.html index.php
</IfModule>
<FilesMatch "^\.ht">
</FilesMatch>
<IfModule log_config_module>
 <IfModule logio_module>
 </IfModule>
</IfModule>
<IfModule alias_module>
 ScriptAlias /cgi-bin/ "/usr/local/www/apache24/cgi-bin/"
</IfModule>
<IfModule cgid_module>
</IfModule>
<Directory "/usr/local/www/apache24/cgi-bin">
 AllowOverride None
 Options None
 Require all granted
</Directory>
<IfModule mime_module>
 TypesConfig etc/apache24/mime.types
 AddType application/x-compress .Z
 AddType application/x-gzip .gz .tgz
 AddType application/x-httpd-php-source .phps
 AddType application/x-httpd-php .php
</IfModule>
<IfModule mod_geoip.c>
  GeoIPEnable On
  GeoIPDBFile /usr/local/share/GeoIP/GeoIPCityIP.dat
</IfModule>

Include etc/apache24/extra/httpd-default.conf
Include etc/apache24/extra/httpd-ssl.conf
Include etc/apache24/Includes/*.conf
IncludeOptional etc/apache24/websites/*.conf
<IfModule ssl_module>
 SSLRandomSeed startup builtin
 SSLRandomSeed connect builtin
</IfModule>
EOF



mv /usr/local/etc/apache24/extra/httpd-ssl.conf /usr/local/etc/apache24/extra/httpd-ssl.conf.old
cat << EOF > /usr/local/etc/apache24/extra/httpd-ssl.conf
Listen 443
AddType application/x-x509-ca-cert .crt
AddType application/x-pkcs7-crl    .crl
SSLPassPhraseDialog  builtin
SSLSessionCache "shmcb:/var/log/web/ssl_scache"
SSLSessionCacheTimeout  300
<VirtualHost _default_:443>
 DocumentRoot "/usr/local/www/apache24/data"
 ServerName localhost:443
 ServerAdmin support@localhost
 LogFormat "%h %l %u %t \"%r\" %>s %b \"%{Referer}i\" \"%{User-Agent}i\""
 TransferLog "|/usr/local/sbin/cronolog /var/log/web/%Y/%m/%d_ssl_access.log"
 ErrorLog "|/usr/local/sbin/cronolog /var/log/web/%Y/%m/%d_ssl_error.log"
 TransferLog "/var/log/httpd-access.log"
 SSLEngine on
 SSLProtocol all -SSLv2
 SSLCipherSuite HIGH:MEDIUM:!aNULL:!MD5
 SSLCertificateFile "/etc/ssl/apache/server.crt"
 SSLCertificateKeyFile "/etc/ssl/apache/server.key"
 <FilesMatch "\.(cgi|shtml|phtml|php)\$">
  SSLOptions +StdEnvVars
 </FilesMatch>
 <Directory "/usr/local/www/apache24/cgi-bin">
  SSLOptions +StdEnvVars
 </Directory>
 BrowserMatch "MSIE [2-5]" \
         nokeepalive ssl-unclean-shutdown \
         downgrade-1.0 force-response-1.0
 CustomLog "/var/log/httpd-ssl_request.log" \
          "%t %h %{SSL_PROTOCOL}x %{SSL_CIPHER}x \"%r\" %b"
</VirtualHost>
EOF


mv /usr/local/etc/apache24/extra/httpd-default.conf /usr/local/etc/apache24/extra/httpd-default.conf.old
cat << EOF > /usr/local/etc/apache24/extra/httpd-default.conf
Timeout 300
KeepAlive On
MaxKeepAliveRequests 100
KeepAliveTimeout 5
UseCanonicalName Off
AccessFileName .htaccess
ServerTokens Prod
ServerSignature Off
HostnameLookups Off
EOF

mkdir -p /usr/local/etc/apache24/websites



mv /usr/local/etc/php.ini /usr/local/etc/php.ini.old
cat << EOF > /usr/local/etc/php.ini
[PHP]
engine = On
short_open_tag = Off
asp_tags = Off
precision = 14
output_buffering = 4096
zlib.output_compression = Off
implicit_flush = Off
unserialize_callback_func =
serialize_precision = 17
disable_functions =
disable_classes =
zend.enable_gc = On
expose_php = Off
max_execution_time = 240
max_input_time = 60
memory_limit = 128M
error_reporting = E_ALL & ~E_DEPRECATED & ~E_STRICT
display_errors = Off
display_startup_errors = Off
log_errors = On
log_errors_max_len = 1024
ignore_repeated_errors = Off
ignore_repeated_source = Off
report_memleaks = On
track_errors = Off
html_errors = On
variables_order = "GPCS"
request_order = "GP"
register_argc_argv = Off
auto_globals_jit = On
post_max_size = 80M
auto_prepend_file =
auto_append_file =
default_mimetype = "text/html"
default_charset = "UTF-8"
include_path = ".:/usr/local/share/pear"
doc_root =
user_dir =
enable_dl = Off
file_uploads = On
upload_max_filesize = 80M
upload_tmp_dir = "/tmp/phpuploads"
max_file_uploads = 20
allow_url_fopen = On
allow_url_include = Off
default_socket_timeout = 60
[CLI Server]
cli_server.color = On
[Date]
date.timezone = "Africa/Johannesburg"
[filter]
[iconv]
[intl]
[sqlite]
[sqlite3]
[Pcre]
[Pdo]
[Pdo_mysql]
pdo_mysql.cache_size = 2000
pdo_mysql.default_socket=
[Phar]
[mail function]
SMTP = localhost
smtp_port = 25
mail.add_x_header = On
[SQL]
sql.safe_mode = Off
[ODBC]
odbc.allow_persistent = On
odbc.check_persistent = On
odbc.max_persistent = -1
odbc.max_links = -1
odbc.defaultlrl = 4096
odbc.defaultbinmode = 1
[Interbase]
ibase.allow_persistent = 1
ibase.max_persistent = -1
ibase.max_links = -1
ibase.timestampformat = "%Y-%m-%d %H:%M:%S"
ibase.dateformat = "%Y-%m-%d"
ibase.timeformat = "%H:%M:%S"
[MySQL]
mysql.allow_local_infile = On
mysql.allow_persistent = On
mysql.cache_size = 2000
mysql.max_persistent = -1
mysql.max_links = -1
mysql.default_port =
mysql.default_socket =
mysql.default_host =
mysql.default_user =
mysql.default_password =
mysql.connect_timeout = 60
mysql.trace_mode = Off
[MySQLi]
mysqli.max_persistent = -1
mysqli.allow_persistent = On
mysqli.max_links = -1
mysqli.cache_size = 2000
mysqli.default_port = 3306
mysqli.default_socket =
mysqli.default_host =
mysqli.default_user =
mysqli.default_pw =
mysqli.reconnect = Off
[mysqlnd]
mysqlnd.collect_statistics = On
mysqlnd.collect_memory_statistics = Off
[OCI8]
[PostgreSQL]
pgsql.allow_persistent = On
pgsql.auto_reset_persistent = Off
pgsql.max_persistent = -1
pgsql.max_links = -1
pgsql.ignore_notice = 0
pgsql.log_notice = 0
[Sybase-CT]
sybct.allow_persistent = On
sybct.max_persistent = -1
sybct.max_links = -1
sybct.min_server_severity = 10
sybct.min_client_severity = 10
[bcmath]
bcmath.scale = 0
[browscap]
[Session]
session.save_handler = files
session.use_cookies = 1
session.use_only_cookies = 1
session.name = impi
session.upload_progress.enabled = On
session.upload_progress.cleanup = On
session.upload_progress.prefix = "upload_progress_"
session.upload_progress.name = "UPLOAD_PROGRESS"
session.upload_progress.min_freq = "%1"
session.auto_start = 0
session.cookie_lifetime = 0
session.cookie_path = /
session.cookie_domain =
session.cookie_httponly =
session.serialize_handler = php
session.gc_probability = 1
session.gc_divisor = 1000
session.gc_maxlifetime = 1440
session.bug_compat_42 = Off
session.bug_compat_warn = Off
session.referer_check =
session.cache_limiter = nocache
session.cache_expire = 180
session.use_trans_sid = 0
session.hash_function = 0
session.hash_bits_per_character = 5
url_rewriter.tags = "a=href,area=href,frame=src,input=src,form=fakeentry"
[MSSQL]
mssql.allow_persistent = On
mssql.max_persistent = -1
mssql.max_links = -1
mssql.min_error_severity = 10
mssql.min_message_severity = 10
mssql.compatability_mode = Off
mssql.secure_connection = Off
[Assertion]
[COM]
[mbstring]
[gd]
[exif]
[Tidy]
tidy.clean_output = Off
[soap]
soap.wsdl_cache_enabled=1
soap.wsdl_cache_dir="/tmp"
soap.wsdl_cache_ttl=86400
soap.wsdl_cache_limit = 5
[sysvshm]
[ldap]
ldap.max_links = -1
[mcrypt]
[dba]
EOF

chmod 644 /usr/local/etc/php.ini
cat << EOF > /usr/local/www/apache24/data/index.php
<?php
phpinfo();
?>
EOF

rm /usr/local/www/apache24/data/index.html

mkdir -p /etc/ssl/apache
cd /etc/ssl/apache
openssl genrsa -des3 -passout pass:x -out server.pass.key 2048
openssl rsa -passin pass:x -in server.pass.key -out server.key
rm server.pass.key
openssl req -new -key server.key -out server.csr \
  -subj "/C=BR/ST=SP/L=Sao_Paulo/O=Enter/OU=HO/CN=localhost"

openssl x509 -req -days 3650 -in server.csr -signkey server.key -out server.crt
cp server.key server.key.orig
openssl rsa -passin pass:x -in server.key.orig -out server.key
chmod 400 /etc/ssl/apache
chmod 400 /etc/ssl/apache/*

EOFB

#############################################


cat << EOF > ENTERBSD 
This is a FreeBSD livecd.
ISO size 231MB

02 January 2018

EOF


cat << EOF > all.log

EOF


cat << EOF > brand-fbsd.4th 
\ Copyright (c) 2006-2015 Devin Teske <dteske\@FreeBSD.org>
\ All rights reserved.
\ 
\ Redistribution and use in source and binary forms, with or without
\ modification, are permitted provided that the following conditions
\ are met:
\ 1. Redistributions of source code must retain the above copyright
\    notice, this list of conditions and the following disclaimer.
\ 2. Redistributions in binary form must reproduce the above copyright
\    notice, this list of conditions and the following disclaimer in the
\    documentation and/or other materials provided with the distribution.
\ 
\ THIS SOFTWARE IS PROVIDED BY THE AUTHOR AND CONTRIBUTORS ``AS IS'' AND
\ ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
\ IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
\ ARE DISCLAIMED.  IN NO EVENT SHALL THE AUTHOR OR CONTRIBUTORS BE LIABLE
\ FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
\ DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
\ OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
\ HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
\ LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
\ OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
\ SUCH DAMAGE.
\ 
\ \$FreeBSD: releng/11.1/sys/boot/forth/brand-fbsd.4th 280975 2015-04-02 01:48:12Z dteske \$

2 brandX ! 1 brandY ! \ Initialize brand placement defaults

: brand+ ( x y c-addr/u -- x y' )
	2swap 2dup at-xy 2swap \ position the cursor
	type \ print to the screen
	1+ \ increase y for next time we're called
;

: brand ( x y -- ) \ "FreeBSD" [wide] logo in B/W (7 rows x 64 columns)

	s"  ______                           ____   _____ _____  " brand+
	s" |  ____|         _               |  _ \ / ____|  __ \ " brand+
	s" | |___   ____  _| |_   ___  _ __ | |_) | (___ | |  | |" brand+
	s" |  ___| |  _ \|_  __| / _ \| '__/|  _ < \___ \| |  | |" brand+
	s" | |     | | | | | |  |  __/| |   | |_) |____) | |__| |" brand+
	s" | |____ | | | | | |_ |    || |   |     |      |      |" brand+
	s" |______||_| |_|  \__| \___||_|   |____/|_____/|_____/ " brand+

	2drop
;
EOF



cat << EOF > console.log

EOF



cat << EOF > dhclient-enter-hooks 
add_new_resolv_conf() {
	 return 0
}

EOF


cat << EOF > enter.logo 
     ________________________________________________________________
    |                                                                |
    |       ______                           ____   _____ _____      |
    |      |  ____|         _               |  _ \ / ____|  __ \     |
    |      | |___   ____  _| |_   ___  _ __ | |_) | (___ | |  | |    |
    |      |  ___| |  _ \|_  __| / _ \| '__/|  _ < \___ \| |  | |    |
    |      | |     | | | | | |  |  __/| |   | |_) |____) | |__| |    |
    |      | |____ | | | | | |_ |    || |   |     |      |      |    |
    |      |______||_| |_|  \__| \___||_|   |____/|_____/|_____/     |
    |                                                                |
    |                                              FreeBSD livecd    |
    |                                                                |
    |                                                                |
    |                                                FreeBSD 11.1    |
    |_______________________________________________________ 2018 ___|




EOF


cat << EOF > enter.rc.d 
#!/bin/sh
#
# \$FreeBSD: releng/11.1/etc/rc.d/enter 273952 2018-01-01 01:47:27Z des \$
#

# PROVIDE: enter
# REQUIRE: bgfsck

. /etc/rc.subr

name="enter"
start_cmd="/usr/sbin/enter"
stop_cmd=":"

load_rc_config \$name
run_rc_command "\$1"

EOF




cat << EOF > enter.sbin 
#!/bin/sh
echo      ""
echo      "  +--------- EnterBSD ----------+"
echo      "  | Starting ...                |"

# startup from harddisk
if [ -e /dev/ada0p3 ]; then
# if [ ! -f /data/startup ]; then
  echo    "  | Mounting data drive ...     |"
  mount /dev/ada0p3 /data
# fi
 echo     "  | Starting everything  ...    |"
 cd /data/
 ./startup

# detect disk
else
 echo     "  | No existing data disk.      |"
 echo     "  | Detecting hard disk ...     |"

# found disk, partition
 if [ -e /dev/ada0 ]; then
  LIST=\$( ls /dev/ada0 )
  SOURCE="/dev/ada0"
  if echo "\$LIST" | grep -q "\$SOURCE"; then
   echo   "  | Found disk ada0 ...         |"
   SOURCE="/dev/ada0p3"
   if echo "\$LIST" | grep -q "\$SOURCE"; then
    echo  "  | Partition p1 not suitable   |"
    echo  "  | for data disk,              |"
    echo  "  | starting livecd ...         |"
   else
    echo  "  | Hard disk format,           |"
    echo  "  | Ctrl-C to abort ...         |"
    read xkey
    gpart create -s GPT ada0
    gpart add -t freebsd-boot -l gpboot -b 40 -s 512K ada0
    cd /mnt
    cd cdrom
    cd boot
    gpart bootcode -b pmbr -p gptboot -i 1 ada0
    gpart add -t freebsd-swap -l gpswap -s 1024M ada0
    gpart add -t freebsd-ufs ada0
    newfs /dev/ada0p3
    cd /data
    tar -pczf /tmp/data.tar.gz .
    mount /dev/ada0p3 /data
    tar -pxvf /tmp/data.tar.gz
    echo  "  | Drive created ...           |"
    mkdir -p /data/disk/mkiso/install/
    cd /mnt/
    cd cdrom/
    cd install/
    cp * /data/disk/mkiso/install/
    cp 0* /data/disk/mkiso/
    cp startup /data/
    /data/startup
   fi
  else
   echo   "  | Cannot find disk ada0 ...   |";
  fi
#  echo "\$LIST"
 else

# run live cd without disk
  echo    "  | No hard disk found,         |"
  echo    "  | Starting livecd ...         |"
  echo    "  |                             |"

  /data/startup

 fi
 echo     "  |                             |"
 echo     "  | Press Enter to login ...    |"
fi
echo      "  +-----------------------------+"
read xkey
if [ -d /mnt/cdrom/install ]; then
 cd /mnt/cdrom/install/
else
 cd /boot
fi
if [ -f enter.logo ]; then
 cat enter.logo
fi

EOF


cat << EOF > fstab.cd 
# Device	Mountpoint	FStype		Options			Dump	Pass#
proc		/proc		procfs		rw			0	0

EOF


cat << EOF > fstab.hd 
# Device	Mountpoint	FStype		Options			Dump	Pass#
/dev/ada0p3	/			ufs			rw			1	1
/dev/ada0p2	none		swap		sw			0	0
proc		/proc		procfs		rw			0	0

EOF


cat << EOF > hosts 
::1			localhost localhost.my.domain
127.0.0.1		localhost localhost.my.domain

EOF


cat << EOF > initboot 
PATH="/rescue"
if [ "\`ps -o command 1 | tail -n 1 | ( read c o; echo \${o} )\`" = "-s" ]; then
 echo "==> Running in single-user mode"
 SINGLE_USER="true"
fi
mount -u -w /
mkdir -p /cdrom /memdisk /livecd
mount_cd9660 /dev/cd0 /cdrom
mdmfs -P -F /cdrom/data/system.uzip -o ro md.uzip /livecd
MEMDISK_SIZE="10240"
echo "EnterBSD mounting memdisk \$MEMDISK_SIZE MB"
mdmfs -s "\${MEMDISK_SIZE}m" md /memdisk || exit 1
mount -t unionfs /memdisk /livecd
mkdir -p /livecd/mnt/cdrom
mount_nullfs -o ro /cdrom /livecd/mnt/cdrom
mount -t devfs devfs /livecd/dev
if [ "\$SINGLE_USER" = "true" ]; then
 echo "Starting interactive shell ..."
 sh
fi
kenv init_shell="/bin/sh"
exit 0

EOF


cat << EOF > loader.conf.cd 
autoboot_delay="5"
loader_logo="enter"
geom_uzip_load="YES"
mfsroot_load="YES"
nullfs_load="YES"
tmpfs_load="YES"
unionfs_load="YES"

mfsroot_type="md_image"
mfsroot_name="/data/ramdisk.ufs"

init_path="/rescue/init"
init_shell="/rescue/sh"
init_script="/initboot"
init_chroot="/livecd"

kern.vty=vt

EOF


cat << EOF > loader.conf.hd 
autoboot_delay="5"
loader_logo="enter"

kern.vty=vt

EOF


cat << EOF > logo-enter.4th 
\ Copyright (c) 2003 Scott Long <scottl@FreeBSD.org>
\ Copyright (c) 2006-2015 Devin Teske <dteske@FreeBSD.org>
\ All rights reserved.
\ 
\ Redistribution and use in source and binary forms, with or without
\ modification, are permitted provided that the following conditions
\ are met:
\ 1. Redistributions of source code must retain the above copyright
\    notice, this list of conditions and the following disclaimer.
\ 2. Redistributions in binary form must reproduce the above copyright
\    notice, this list of conditions and the following disclaimer in the
\    documentation and/or other materials provided with the distribution.
\ 
\ THIS SOFTWARE IS PROVIDED BY THE AUTHOR AND CONTRIBUTORS ``AS IS'' AND
\ ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
\ IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
\ ARE DISCLAIMED.  IN NO EVENT SHALL THE AUTHOR OR CONTRIBUTORS BE LIABLE
\ FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
\ DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
\ OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
\ HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
\ LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
\ OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
\ SUCH DAMAGE.
\ 
\ \$FreeBSD: releng/11.1/sys/boot/forth/logo-fbsdbw.4th 280975 2015-04-02 01:48:12Z dteske \$

52 logoX ! 9 logoY ! \ Initialize logo placement defaults

: logo+ ( x y c-addr/u -- x y' )
	2swap 2dup at-xy 2swap \ position the cursor
	type \ print to the screen
	1+ \ increase y for next time we're called
;

: logo ( x y -- ) \ color BSD mascot (16 rows x 34 columns)

	s"          ___      __    " logo+
	s"  _  _   /   \    /  |   " logo+
	s" | || | | | | |    | |   " logo+
	s" | || | | |_| | _  | |   " logo+
	s"  \__/   \___/ |_||___|  " logo+
	s"                         " logo+
	s"                         " logo+
	s" FreeBSD livecd          " logo+
	s"                         " logo+
	s"                         " logo+
	s"                         " logo+
	s"                         " logo+
	s"                         " logo+
	s" FreeBSD 11.1-RELEASE-p4 " logo+
	s"                         " logo+

	2drop
;

EOF



cat << EOF > motd 




                        +-----------------------------+
                        |                             |
                        |    Welcome to EnterBSD.     |
                        |                             |
                        |       Now please leave.     |
                        |                             |
                        +-----------------------------+




EOF



cat << EOF > rc.conf
clear_tmp_enable="YES"
update_motd_enable="NO"
sendmail_enable="NONE"
hostid_enable="NO"
hostname="localhost.my.domain"
dumpdev="NO"
sshd_enable="YES"
enter_enable="YES"

EOF

cat << EOF > rc.conf.small 
root_rw_mount="NO"
update_motd="NO"
cleanvar_enable="NO"
hostid_enable="NO"
hostname="localhost.local.lan"
sendmail_enable="NONE"
sendmail_submit_enable="NO"
sendmail_outbound_enable="NO"
sendmail_msp_queue_enable="NO"

enter_enable="YES"

EOF


cat << EOF > rc.conf.big 
clear_tmp_enable="YES"
update_motd="NO"
sendmail_enable="NONE"
sendmail_submit_enable="NO"
sendmail_outbound_enable="NO"
sendmail_msp_queue_enable="NO"
hostname="enter.local.lan"
keymap="br"
ifconfig_em0="inet 192.168.1.25/24"
defaultrouter="192.168.1.2"
sshd_enable="YES"
samba_server_enable="YES"
named_enable="YES"
dhcpd_enable="YES"
openvpn_enable="YES"
openvpn_configfile="/usr/local/etc/openvpn/openvpn.conf"
openvpn_dir="/usr/local/etc/openvpn"
openvpn_if="tap"
apache24_enable="YES"
mysql_enable="YES"
squid_enable="YES"
postfix_enable="YES"
dovecot_enable="YES"
rpcbind_enable="YES"
nfs_server_enable="YES"
nfsv4_server_enable="YES"
mountd_flags="-r"
ntpd_enable="NO"
openntpd_enable="YES"
#ntpdate_enable="YES"
spamassassin_enable="YES"
clamav_freshclam_enable="YES"
clamav_clamd_enable="YES"
spamd_enable="YES"
svnserve_enable="YES"
maiad_enable="YES"

EOF

 
cat << EOF > resolv.conf 
nameserver 127.0.0.1
nameserver 8.8.8.8

EOF


cat << EOF > startup 
#!/bin/sh
echo      "  | /data/startup ...           |"
cp /etc/rc.conf.big /etc/rc.conf
dhclient em0
service sshd start
#service openntpd start
#service apache24 start
#service clamav-freshclam start
#service clamav-clamd start
#service dovecot start
#service isc-dhcpd start
#service mysql-server start
#service named start
#service openvpn start
#service postfix start
#service sa-spamd start
#service samba_server start
#service squid start
#service nfsd start
#service svnserve start
echo      "  | All ready ...               |"

EOF



cat << EOF > sysctl.conf 
# \$FreeBSD: releng/11.1/etc/sysctl.conf 112200 2003-03-13 18:43:50Z mux \$
#
#  This file is read when going to multi-user and its contents piped thru
#  ``sysctl'' to adjust kernel values.  ``man 5 sysctl.conf'' for details.
#

# Uncomment this to prevent users from seeing information about processes that
# are being run under another UID.
#security.bsd.see_other_uids=0
security.bsd.unprivileged_read_msgbuf=0
security.bsd.unprivileged_proc_debug=0
kern.randompid=8807
security.bsd.stack_guard_page=1
net.inet.ip.random_id=1
vfs.usermount=1

EOF



cat << EOF > syslog.conf 
# \$FreeBSD: releng/11.1/etc/syslog.conf 308721 2016-11-16 07:04:49Z bapt \$
#
#	Spaces ARE valid field separators in this file. However,
#	other *nix-like systems still insist on using tabs as field
#	separators. If you are sharing this file between systems, you
#	may want to use only tabs as field separators here.
#	Consult the syslog.conf(5) manpage.
*.err;kern.warning;auth.notice;mail.crit		/dev/null
*.notice;authpriv.none;kern.debug;lpr.info;mail.crit;news.err	/var/log/messages
security.*					/var/log/security
auth.info;authpriv.info				/var/log/auth.log
mail.info					/var/log/maillog
lpr.info					/var/log/lpd-errs
ftp.info					/var/log/xferlog
cron.*						/var/log/cron
!-devd
*.=debug					/var/log/debug.log
*.emerg						*
# uncomment this to log all writes to /dev/console to /var/log/console.log
# touch /var/log/console.log and chmod it to mode 600 before it will work
console.info					/var/log/console.log
# uncomment this to enable logging of all log messages to /var/log/all.log
# touch /var/log/all.log and chmod it to mode 600 before it will work
*.*						/var/log/all.log
# uncomment this to enable logging to a remote loghost named loghost
#*.*						@loghost
# uncomment these if you're running inn
# news.crit					/var/log/news/news.crit
# news.err					/var/log/news/news.err
# news.notice					/var/log/news/news.notice
# Uncomment this if you wish to see messages produced by devd
# !devd
# *.>=notice					/var/log/devd.log
!ppp
*.*						/var/log/ppp.log
!*
include						/etc/syslog.d
include						/usr/local/etc/syslog.d

EOF



cp ENTERBSD /
cd /rescue
tar -pczf /1/install/9rescue.tar.gz .
cd /1/install/
cp /boot/cdboot .
cp /etc/master.passwd .
cp /etc/passwd .
cp /etc/pwd.db .
cp /etc/group .

chmod +x 0* 8* 7* enter.rc.d enter.sbin initboot startup
chmod 666 *.log
cp 0* ..
cd /1
ls -l

