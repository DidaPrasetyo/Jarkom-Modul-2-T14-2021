if [[ $(hostname) = "Loguetown" ]]; then
	echo 'nameserver 192.218.2.2
	nameserver 192.218.2.3
	nameserver 192.168.122.1' > /etc/resolv.conf
elif [[ $(hostname) = "Alabasta" ]]; then
	echo 'nameserver 192.218.2.2
	nameserver 192.218.2.3
	nameserver 192.168.122.1' > /etc/resolv.conf
elif [[ $(hostname) = "EniesLobby" ]]; then
	echo '
	zone "franky.TI14.com" {
	    type master;
	    notify yes;
	    also-notify { 192.218.2.3; };
	    allow-transfer { 192.218.2.3; };
	    file "/etc/bind/kaizoku/franky.TI14.com";
	};

	zone "2.218.192.in-addr.arpa" {
	    type master;
	    file "/etc/bind/kaizoku/2.218.192.in-addr.arpa";
	};
	' > /etc/bind/named.conf.local

	echo '
	options {
	    directory "/var/cache/bind";

	    // forwarders {
	    //      0.0.0.0;
	    // };

	    
	    //dnssec-validation auto;
	    allow-query{any;};

	    auth-nxdomain no;    # conform to RFC1035
	    listen-on-v6 { any; };
	};
	' > /etc/bind/named.conf.options

	mkdir /etc/bind/kaizoku

	echo '
	$TTL    604800
	@       IN      SOA     franky.TI14.com. root.franky.TI14.com. (
	                        2021102601      ; Serial
	                         604800         ; Refresh
	                          86400         ; Retry
	                        2419200         ; Expire
	                         604800 )       ; Negative Cache TTL
	;
	@       IN      NS      franky.TI14.com.
	@       IN      A       192.218.2.4
	www     IN      CNAME   franky.TI14.com.
	super   IN      A       192.218.2.4
	www.super       IN      CNAME   super.franky.TI14.com.
	ns1     IN      A       192.218.2.3
	mecha   IN      NS      ns1
	' > /etc/bind/kaizoku/franky.TI14.com

	echo '
	$TTL    604800
	@       IN      SOA     franky.TI14.com. root.franky.TI14.com. (
	                        2021102601      ; Serial
	                         604800         ; Refresh
	                          86400         ; Retry
	                        2419200         ; Expire
	                         604800 )       ; Negative Cache TTL
	;
	2.218.192.in-addr.arpa. IN      NS      franky.TI14.com.
	2       IN      PTR     franky.TI14.com.
	' > /etc/bind/kaizoku/2.218.192.in-addr.arpa

	service bind9 restart
elif [[ $(hostname) = "Water7" ]]; then
	echo 'nameserver 192.218.2.2 
	nameserver 192.168.122.1' > /etc/resolv.conf

	echo '
	zone "franky.TI14.com" {
	    type slave;
	    masters { 192.218.2.2; };
	    file "/var/lib/bind/franky.TI14.com";
	};

	zone "mecha.franky.TI14.com" {
	    type master;
	    file "/etc/bind/sunnygo/mecha.franky.TI14.com";
	};' > /etc/bind/named.conf.local

	echo '
	options {
	    directory "/var/cache/bind";

	    // forwarders {
	    //      0.0.0.0;
	    // };

	    
	    //dnssec-validation auto;
	    allow-query{any;};

	    auth-nxdomain no;    # conform to RFC1035
	    listen-on-v6 { any; };
	};
	' > /etc/bind/named.conf.options

	mkdir /etc/bind/sunnygo

	echo '
	$TTL    604800
	@       IN      SOA     mecha.franky.TI14.com. root.mecha.franky.TI14.com. (
	                        2021102601      ; Serial
	                         604800         ; Refresh
	                          86400         ; Retry
	                        2419200         ; Expire
	                         604800 )       ; Negative Cache TTL
	;
	@       IN      NS      mecha.franky.TI14.com.
	@       IN      A       192.218.2.4
	www     IN      CNAME   mecha.franky.TI14.com.
	general IN      A       192.218.2.4
	www.general     IN      CNAME   general.mecha.franky.TI14.com.
	' > /etc/bind/sunnygo/mecha.franky.TI14.com

	service bind9 restart
elif [[ $(hostname) = "Skypie" ]]; then
	mkdir /var/www/franky.TI14.com
	wget https://github.com/FeinardSlim/Praktikum-Modul-2-Jarkom/raw/main/franky.zip -P /var/www/franky.TI14.com
	unzip franky.zip
	mv franky/* ../franky.TI14.com
	rmdir franky
	rm franky.zip

	mkdir /var/www/super.franky.TI14.com
	wget https://github.com/FeinardSlim/Praktikum-Modul-2-Jarkom/raw/main/super.franky.zip -P /var/www/super.franky.TI14.com
	unzip super.franky.zip
	mv super.franky/* ../super.franky.TI14.com
	rmdir super.franky
	rm super.franky.zip

	mkdir /var/www/general.mecha.franky.TI14.com
	wget https://github.com/FeinardSlim/Praktikum-Modul-2-Jarkom/raw/main/general.mecha.franky.zip -P /var/www/general.mecha.franky.TI14.com
	unzip general.mecha.franky.zip
	mv general.mecha.franky/* ../general.mecha.franky.TI14.com
	rmdir general.mecha.franky
	rm general.mecha.franky.zip

	echo '
	<VirtualHost *:80>
	    ServerAdmin webmaster@localhost
	    ServerName franky.TI14.com
	    ServerAlias www.franky.TI14.com
	    DocumentRoot /var/www/franky.TI14.com
	    Alias "/home" "/var/www/franky.TI14.com/index.php"

	    ErrorLog ${APACHE_LOG_DIR}/error.log
	    CustomLog ${APACHE_LOG_DIR}/access.log combined
	</VirtualHost>
	' > /etc/apache2/sites-available/franky.TI14.com.conf

	echo '
	<VirtualHost *:80>
	    ServerAdmin webmaster@localhost
	    ServerName super.franky.TI14.com
	    ServerAlias www.super.franky.TI14.com
	    DocumentRoot /var/www/super.franky.TI14.com
	    Alias "/js" "/var/www/super.franky.TI14.com/public/js"

	    <Directory /var/www/super.franky.TI14.com/public>
	    	Options +Indexes
	    </Directory>

	    <Directory /var/www/super.franky.TI14.com/public/css>
	    	Options -Indexes
	    </Directory>

	    <Directory /var/www/super.franky.TI14.com/public/images>
	    	Options -Indexes
	    </Directory>

	    <Directory /var/www/super.franky.TI14.com/public/js>
	    	Options +Indexes
	    </Directory>

	    ErrorDocument 404 /error/404.html

	    ErrorLog ${APACHE_LOG_DIR}/error.log
	    CustomLog ${APACHE_LOG_DIR}/access.log combined
	</VirtualHost>
	' > /etc/apache2/sites-available/super.franky.TI14.com.conf

	echo '
	<VirtualHost *:15000 *:15500>
	    ServerAdmin webmaster@localhost
	    ServerName general.mecha.franky.TI14.com
	    ServerAlias www.general.mecha.franky.TI14.com
	    DocumentRoot /var/www/general.mecha.franky.TI14.com

	    ErrorLog ${APACHE_LOG_DIR}/error.log
	    CustomLog ${APACHE_LOG_DIR}/access.log combined
	</VirtualHost>
	' > /etc/apache2/sites-available/general.mecha.franky.TI14.com.conf

	htpasswd -b -c /var/www/general.mecha.franky.TI14 luffy onepiece

	a2ensite franky.TI14.com
	a2ensite super.franky.TI14.com
	a2ensite general.mecha.franky.TI14.com
	a2dissite 000-default

	service apache2 restart

fi