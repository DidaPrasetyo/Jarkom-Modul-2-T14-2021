# Jarkom-Modul-2-T14-2021

Anggota Kelompok :
- Dida Prasetyo Rahmat - 05311940000019 
- Revina Rahmanisa Harjanto - 05311940000046 

## 1. EniesLobby akan dijadikan sebagai DNS Master, Water7 akan dijadikan DNS Slave, dan Skypie akan digunakan sebagai Web Server. Terdapat 2 Client yaitu Loguetown, dan Alabasta. Semua node terhubung pada router Foosha, sehingga dapat mengakses internet

![soal 1 - screenshot 2](images/pict1.png)

### a. Foosha
```
auto eth0
iface eth0 inet dhcp
auto eth1
iface eth1 inet static
	address 192.218.1.1
	netmask 255.255.255.0
auto eth2
iface eth2 inet static
	address 192.218.2.1
	netmask 255.255.255.0
```

### b. Loguetown
```
auto eth0
iface eth0 inet static
	address 192.218.1.2
	netmask 255.255.255.0
	gateway 192.218.1.1
```

### c. Alabasta
```
auto eth0
iface eth0 inet static
	address 192.218.1.3
	netmask 255.255.255.0
	gateway 192.218.1.1
```

### d. EniesLobby
```
auto eth0
iface eth0 inet static
	address 192.218.2.2
	netmask 255.255.255.0
	gateway 192.218.2.1
```

### e. Water7
```
auto eth0
iface eth0 inet static
	address 192.218.2.3
	netmask 255.255.255.0
	gateway 192.218.2.1
```

### f. Skypie
```
auto eth0
iface eth0 inet static
	address 192.218.2.4
	netmask 255.255.255.0
	gateway 192.218.2.1
```


## 2. Luffy ingin menghubungi Franky yang berada di EniesLobby dengan denden mushi. Kalian diminta Luffy untuk membuat website utama dengan mengakses franky.yyy.com dengan alias www.franky.yyy.com pada folder kaizoku

### a. `/etc/bind/named.conf.local` (EniesLobby)
```
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
```

### b. `/etc/bind/named.conf.options` (EniesLobby)
```
zone "franky.TI14.com" {
    type master;
    file "/etc/bind/kaizoku/franky.TI14.com";
};
```

## 3. Setelah itu buat subdomain super.franky.yyy.com dengan alias www.super.franky.yyy.com yang diatur DNS nya di EniesLobby dan mengarah ke Skypie

### a. `/etc/bind/named.conf.local` (EniesLobby)
```
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
```

## 4. Buat juga reverse domain untuk domain utama

### a. `/etc/bind/named.conf.local` (EniesLobby)
```
	...
	zone "2.218.192.in-addr.arpa" {
	    type master;
	    file "/etc/bind/kaizoku/2.218.192.in-addr.arpa";
	};
```

### b. `/etc/bind/kaizoku/2.218.192.in-addr.arpa` (EniesLobby)
```
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
```


## 5. Supaya tetap bisa menghubungi Franky jika server EniesLobby rusak, maka buat Water7 sebagai DNS Slave untuk domain utama

### a. `/etc/bind/named.conf.local` (EniesLobby)
```
zone "franky.TI14.com" {
    type master;
    notify yes;
    also-notify { 192.218.2.3; };
    allow-transfer { 192.218.2.3; };
    file "/etc/bind/kaizoku/franky.TI14.com";
};
...
```

### b. `/etc/bind/named.conf.local` (Water7)
```
zone "franky.TI14.com" {
    type slave;
    masters { 192.218.2.2; };
    file "/var/lib/bind/franky.TI14.com";
};
```

## 6. Setelah itu terdapat subdomain mecha.franky.yyy.com dengan alias www.mecha.franky.yyy.com yang didelegasikan dari EniesLobby ke Water7 dengan IP menuju ke Skypie dalam folder sunnygo

### a. `/etc/bind/kaizoku/franky.TI14.com` (EniesLobby)
```
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
```

### b. `/etc/bind/named.conf.options` (EniesLobby)
```
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
```

### c. `/etc/bind/named.conf.local` (EniesLobby)
```
zone "franky.TI14.com" {
    type master;
    notify yes;
    also-notify { 192.218.2.3; };
    allow-transfer { 192.218.2.3; }; //Sudah ada
    file "/etc/bind/kaizoku/franky.TI14.com";
};
```

### d. `/etc/bind/named.conf.options` (Water7)
```
options {
    directory "/var/cache/bind";
    // forwarders {
    //      0.0.0.0;
    // };	    

    //dnssec-validation auto;
    allow-query{any;};
    auth-nxdomain no;    # conform to RFC1035
    listen-on-v6 { any; };
```

### e. `/etc/bind/named.conf.local` (Water7)
```
zone "franky.TI14.com" {
    type slave;
    masters { 192.218.2.2; };
    file "/var/lib/bind/franky.TI14.com";
};
```

### f. `/etc/bind/sunnygo/mecha.franky.TI14.com` (Water7)
```
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
```

## 7. Untuk memperlancar komunikasi Luffy dan rekannya, dibuatkan subdomain melalui Water7 dengan nama general.mecha.franky.yyy.com dengan alias www.general.mecha.franky.yyy.com yang mengarah ke Skypie

### a. `/etc/bind/sunnygo/mecha.franky.TI14.com` (water7)
```
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
```

## 8. Setelah melakukan konfigurasi server, maka dilakukan konfigurasi Webserver. Pertama dengan webserver www.franky.yyy.com. Pertama, luffy membutuhkan webserver dengan DocumentRoot pada /var/www/franky.yyy.com.

### a. `/etc/apache2/sites-available/franky.TI14.com.conf` (Skypie)
```
<VirtualHost *:80>
    ServerAdmin webmaster@localhost
    ServerName franky.TI14.com
    ServerAlias www.franky.TI14.com
    DocumentRoot /var/www/franky.TI14.com

    ErrorLog ${APACHE_LOG_DIR}/error.log
    CustomLog ${APACHE_LOG_DIR}/access.log combined
</VirtualHost>
```

### b. Eksekusi command
```
mkdir /var/www/franky.TI14.com
wget https://github.com/FeinardSlim/Praktikum-Modul-2-Jarkom/raw/main/franky.zip -P /var/www/franky.TI14.com
unzip franky.zip
mv franky/* ../franky.TI14.com
rmdir franky
rm franky.zip
a2ensite franky.TI14.com
```

## 9. Setelah itu, Luffy juga membutuhkan agar url www.franky.yyy.com/index.php/home dapat menjadi menjadi www.franky.yyy.com/home

### a. `/etc/apache2/sites-available/franky.TI14.com.conf` (Skypie)
```
<VirtualHost *:80>
    ServerAdmin webmaster@localhost
    ServerName franky.TI14.com
    ServerAlias www.franky.TI14.com
    DocumentRoot /var/www/franky.TI14.com
    Alias "/home" "/var/www/franky.TI14.com/index.php"
    ErrorLog ${APACHE_LOG_DIR}/error.log
    CustomLog ${APACHE_LOG_DIR}/access.log combined
</VirtualHost>
```
## 10. Setelah itu, pada subdomain www.super.franky.yyy.com, Luffy membutuhkan penyimpanan aset yang memiliki DocumentRoot pada /var/www/super.franky.yyy.com

### a. `/etc/apache2/sites-available/super.franky.TI14.com.conf` (Skypie)
```
<VirtualHost *:80>
    ServerAdmin webmaster@localhost
    ServerName super.franky.TI14.com
    ServerAlias www.super.franky.TI14.com
    DocumentRoot /var/www/super.franky.TI14.com

    ErrorLog ${APACHE_LOG_DIR}/error.log
    CustomLog ${APACHE_LOG_DIR}/access.log combined
</VirtualHost>
```

### b. Eksekusi Command
```
mkdir /var/www/super.franky.TI14.com
wget https://github.com/FeinardSlim/Praktikum-Modul-2-Jarkom/raw/main/super.franky.zip -P /var/www/super.franky.TI14.com
unzip super.franky.zip
mv super.franky/* ../super.franky.TI14.com
rmdir super.franky
rm super.franky.zip
a2ensite super.franky.TI14.com
```

## 11. Akan tetapi, pada folder /public, Luffy ingin hanya dapat melakukan directory listing saja

### a. `/etc/apache2/sites-available/super.franky.TI14.com.conf` (Skypie)
```
...

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

...
```

## 12. Tidak hanya itu, Luffy juga menyiapkan error file 404.html pada folder /error untuk mengganti error kode pada apache .

### a. `/etc/apache2/sites-available/super.franky.TI14.com.conf` (Skypie)
```
...

ErrorDocument 404 /error/404.html

...
```

## 13. Luffy juga meminta Nami untuk dibuatkan konfigurasi virtual host. Virtual host ini bertujuan untuk dapat mengakses file asset www.super.franky.yyy.com/public/js menjadi www.super.franky.yyy.com/js. 

### a. /etc/apache2/sites-available/super.franky.TI14.com.conf
```
...

Alias "/js" "/var/www/super.franky.TI14.com/public/js"

...
```

## 14. Dan Luffy meminta untuk web www.general.mecha.franky.yyy.com hanya bisa diakses dengan port 15000 dan port 15500

### a. `/etc/apache2/sites-available/general.mecha.franky.TI14.com.conf` (Skypie)

```
<VirtualHost *:15000 *:15500>
    ServerAdmin webmaster@localhost
    ServerName general.mecha.franky.TI14.com
    ServerAlias www.general.mecha.franky.TI14.com
    DocumentRoot /var/www/general.mecha.franky.TI14.com

    ErrorLog ${APACHE_LOG_DIR}/error.log
    CustomLog ${APACHE_LOG_DIR}/access.log combined
</VirtualHost>
```

### b. Eksekusi Command
```
mkdir /var/www/general.mecha.franky.TI14.com
wget https://github.com/FeinardSlim/Praktikum-Modul-2-Jarkom/raw/main/general.mecha.franky.zip -P /var/www/general.mecha.franky.TI14.com
unzip general.mecha.franky.zip
mv general.mecha.franky/* ../general.mecha.franky.TI14.com
rmdir general.mecha.franky
rm general.mecha.franky.zip
a2ensite general.mecha.franky.TI14.com
```
## 15. dengan autentikasi username luffy dan password onepiece dan file di /var/www/general.mecha.franky.yyy

htpasswd -b -c /var/www/general.mecha.franky.TI14 luffy onepiece

## 16. Dan setiap kali mengakses IP Skypie akan dialihkan secara otomatis ke www.franky.yyy.com

Saat dicoba kemarin sudah bisa langsung menampilkan halaman yang sama dengan www.franky.TI14.com

## 17. Dikarenakan Franky juga ingin mengajak temannya untuk dapat menghubunginya melalui website www.super.franky.yyy.com, dan dikarenakan pengunjung web server pasti akan bingung dengan randomnya images yang ada, maka Franky juga meminta untuk mengganti request gambar yang memiliki substring “franky” akan diarahkan menuju franky.png.

```
-
```

## Kendala : 
- Kesulitan saat membuat autentikasi
