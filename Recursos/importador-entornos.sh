# /home/ezequiel/www/tiendalosangeles
# /home/develop/tiendalosangeles_backup_2019-09-12.zip
# https://github.com/kudosestudio/tienda-los-angeles.git
# ezequiel_tiendalosangeles
# develop
# Developers2017
# http://felix.tiendalosangeles.com.ar/

if [ "$EUID" -ne 0 ]
  then echo "Ejecutar este script con sudo."
  exit
fi
echo 'Escribe la ruta absoluta en donde estarán los archivos del proyecto (el contenido de la carpeta se pisará):'
read project_route
echo 'Escribe la ruta absoluta al comprimido zip del proyecto:'
read project_zip
echo 'Escribe la subcarpeta donde se encuentra el proyecto (en caso que la plataforma se haya instalado en una subcarpeta dentro del repo). Ejemplo: ("/tiendalibero"):'
read project_subfolder
echo 'Escribe el nombre del nuevo usuario dueño del proyecto:'
read project_owner
echo '¿Realizar vinculación con repositorio? (si/no):'
read sync_repo
if [ "$sync_repo" = "si" ]
  then
  echo 'Escribe la url https del repositorio GIT (Ejemplo: "https://github.com/kudosestudio/nhautopiezas.git"):'
  read project_git
fi
echo 'Escribe el nombre de la base de datos (si existe se pisará):'
read project_bbdd
echo 'Usuario de base de datos:'
read bbdd_user
echo 'Password de base de datos:'
read bbdd_pass
echo '¿El proyecto a importar es Magento? (si/no):'
read platform_magento
if [ "$platform_magento" = "si" ]
then
echo 'Versión de magento (1/2):'
read magento_version
echo 'Escribe la NUEVA url completa del proyecto: (Ejemplo: "http://ezequiel.nhautopiezas.com.ar/"):'
read platform_url
echo 'Escribe dominio del proyecto: (Ejemplo: "ezequiel.nhautopiezas.com.ar"):'
read platform_domain
echo 'Versión PHP del proyecto: (5.6/7.0/7.1/7.2):'
read platform_php
echo 'Ingrese el prefijo de las tablas (dejar vacío en caso que no corresponda):'
read magento_table_prefix
fi

# repeating process
echo "Comienza importación." &&
echo "Creando ruta e inicializando proyecto..." &&
sleep 2 &&
rm -rf $project_route
mkdir -p $project_route &&
cd $project_route
if [ "$sync_repo" = "si" ]
  then
  echo "Inicializando GIT..." &&
  git init &&
  git remote add origin $project_git &&
  git fetch --all &&
  git checkout staging
fi

echo "Extrayendo archivos..." &&
sleep 2 &&
unzip -o $project_zip &&
git status &&

echo "Creando e importando base de datos ${platform_domain}..." &&
sleep 2 &&
echo "drop database $project_bbdd" | mysql -u $bbdd_user -p$bbdd_pass 2> /dev/null
echo "create database $project_bbdd" | mysql -u $bbdd_user -p$bbdd_pass 2> /dev/null
zcat bbdd_backup.sql.gz | mysql -u $bbdd_user -p$bbdd_pass $project_bbdd 2> /dev/null

if [ "$platform_magento" = "si" ]
then
echo "Corrigiendo dominio, emails de clientes y optimizando la bbdd de Magento..." &&
sleep 2 &&
echo "update core_config_data set value = \"${platform_url}\" where path like \"%base_url%\" or path like \"%base_link_url%\"" | mysql -u $bbdd_user -p$bbdd_pass $project_bbdd 2> /dev/null
echo "update sales_order set customer_email = replace(customer_email , \"@\", \"@testk\")" | mysql -u $bbdd_user -p$bbdd_pass $project_bbdd 2> /dev/null
echo "update sales_flat_order set customer_email = replace(customer_email , \"@\", \"@testk\")" | mysql -u $bbdd_user -p$bbdd_pass $project_bbdd 2> /dev/null
echo "update customer_entity set email = replace(email, \"@\", \"@testk\");" | mysql -u $bbdd_user -p$bbdd_pass $project_bbdd 2> /dev/null

echo "Corrigiendo acceso a la base de datos..." &&
mkdir -p /etc/nginx/sites-available/${project_owner}
sleep 2 &&
if [ "$magento_version" = "1" ]
then
cat > .${project_subfolder}/app/etc/local.xml <<EOL
<?xml version="1.0"?>
<config>
  <global>
    <install>
      <date><![CDATA[Wed, 27 Dec 2017 10:57:49 -0200]]></date>
    </install>
    <crypt>
      <key><![CDATA[c02gnol74xfnd2ntburbhqcvt3yvnhxp]]></key>
    </crypt>
    <disable_local_modules>false</disable_local_modules>
    <resources>
      <db>
        <table_prefix><![CDATA[${magento_table_prefix}]]></table_prefix>
      </db>
      <default_setup>
        <connection>
          <host><![CDATA[localhost]]></host>
          <username><![CDATA[${bbdd_user}]]></username>
          <password><![CDATA[${bbdd_pass}]]></password>
          <dbname><![CDATA[${project_bbdd}]]></dbname>
          <initStatements><![CDATA[SET NAMES utf8]]></initStatements>
          <model><![CDATA[mysql4]]></model>
          <type><![CDATA[pdo_mysql]]></type>
          <pdoType><![CDATA[]]></pdoType>
          <active>1</active>
        </connection>
      </default_setup>
    </resources>
    <session_save><![CDATA[files]]></session_save>
  </global>
  <admin>
    <routers>
      <adminhtml>
        <args>
          <frontName><![CDATA[kpanel]]></frontName>
        </args>
      </adminhtml>
    </routers>
  </admin>
</config>
EOL
cat > /etc/nginx/sites-available/${project_owner}/${platform_domain} <<EOL
server {
	listen 80;
	root ${project_route}${project_subfolder};
	index index.php index.html index.htm;

	server_name ${platform_domain};
	access_log /var/log/nginx/${platform_domain}_access.log;
	access_log /var/log/nginx/${platform_domain}_error.log;

	location ^~ /app/                { deny all; }
	location ^~ /includes/           { deny all; }
	location ^~ /lib/                { deny all; }
	location ^~ /media/downloadable/ { deny all; }
	location ^~ /pkginfo/            { deny all; }
	location ^~ /report/config.xml   { deny all; }
	location ^~ /var/                { deny all; }
	location /var/export/            { deny all; }

	location ~ /\. {
		deny  all;
		access_log off;
		log_not_found off;
	}

	location ~*  \.(jpg|jpeg|png|gif|ico)\$ {
		expires 365d;
		log_not_found off;
		access_log off;
	}

	location ~ .php/ { ## Forward paths like /js/index.php/x.js to relevant handler
		rewrite ^(.*.php)/ \$1 last;
    }

	location / {
		index index.html index.php;
		try_files \$uri \$uri/ /index.php?\$query_string;
		expires 30d;
		rewrite /api/rest /api.php?type=rest;
    }

	# pass the PHP scripts to FPM socket
	location ~ \.php\$ {
		fastcgi_pass unix:/var/run/php/php${platform_php}-fpm.sock;
		fastcgi_param MAGE_RUN_TYPE store;
		fastcgi_index index.php;
		include fastcgi.conf;
    }
}
EOL
echo "Actualizando permisos de los archivos..."
cd .${project_subfolder}
chown -R www-data:$project_owner . && chmod -R 777 var/
fi
if [ "$magento_version" = "2" ]
then
cat > .${project_subfolder}/app/etc/env.php <<EOL
<?php
return [
  'backend' => [
    'frontName' => 'kpanel'
  ],
  'crypt' => [
    'key' => 'eeaa9f31a8c5112834f0cc552a6204a8'
  ],
  'db' => [
    'table_prefix' => '${magento_table_prefix}',
    'connection' => [
      'default' => [
        'host' => 'localhost',
        'dbname' => '${project_bbdd}',
        'username' => '${bbdd_user}',
        'password' => '${bbdd_pass}',
        'model' => 'mysql4',
        'engine' => 'innodb',
        'initStatements' => 'SET NAMES utf8;',
        'active' => '1'
      ]
    ]
  ],
  'resource' => [
    'default_setup' => [
      'connection' => 'default'
    ]
  ],
  'x-frame-options' => 'SAMEORIGIN',
  'MAGE_MODE' => 'developer',
  'session' => [
    'save' => 'files'
  ],
  'cache_types' => [
    'config' => 1,
    'layout' => 1,
    'block_html' => 1,
    'collections' => 1,
    'reflection' => 1,
    'db_ddl' => 1,
    'eav' => 1,
    'customer_notification' => 1,
    'config_integration' => 1,
    'config_integration_api' => 1,
    'full_page' => 1,
    'config_webservice' => 1,
    'translate' => 1,
    'compiled_config' => 1,
    'wp_gtm_categories' => 1
  ],
  'install' => [
    'date' => 'Wed, 10 Oct 2018 16:17:12 +0000'
  ],
  'system' => [
    'default' => [
      'dev' => [
        'debug' => [
          'debug_logging' => '0'
        ]
      ]
    ]
  ]
];
EOL
cat > /etc/nginx/sites-available/${project_owner}/${platform_domain} <<EOL
server {
    listen 80;
    server_name ${platform_domain};
    set \$MAGE_ROOT ${project_route}${project_subfolder};
    set \$MAGE_MODE developer;

    root \$MAGE_ROOT/pub;
    index index.php;
    autoindex off;
    charset off;

    add_header 'X-Content-Type-Options' 'nosniff';
    add_header 'X-XSS-Protection' '1; mode=block';

    location /setup {
        root \$MAGE_ROOT;
        location ~ ^/setup/index.php {
            fastcgi_pass   unix:/var/run/php/php${platform_php}-fpm.sock;
            fastcgi_index  index.php;
            fastcgi_param  SCRIPT_FILENAME  \$document_root\$fastcgi_script_name;
            include        fastcgi_params;
        }

        location ~ ^/setup/(?!pub/). {
            deny all;
        }

        location ~ ^/setup/pub/ {
            add_header X-Frame-Options "SAMEORIGIN";
        }
    }

    location /update {
        root \$MAGE_ROOT;

        location ~ ^/update/index.php {
            fastcgi_split_path_info ^(/update/index.php)(/.+)\$;
            fastcgi_pass   unix:/var/run/php/php${platform_php}-fpm.sock;
            fastcgi_index  index.php;
            fastcgi_param  SCRIPT_FILENAME  \$document_root\$fastcgi_script_name;
            fastcgi_param  PATH_INFO        \$fastcgi_path_info;
            include        fastcgi_params;
        }

        # deny everything but index.php
        location ~ ^/update/(?!pub/). {
            deny all;
        }

        location ~ ^/update/pub/ {
            add_header X-Frame-Options "SAMEORIGIN";
        }
    }

    location / {
        try_files \$uri \$uri/ /index.php?\$args;
    }

    location /pub {
        location ~ ^/pub/media/(downloadable|customer|import|theme_customization/.*\.xml) {
            deny all;
        }
        alias \$MAGE_ROOT/pub;
        add_header X-Frame-Options "SAMEORIGIN";
    }

    location /static/ {
        if (\$MAGE_MODE = "production") {
            expires max;
        }
        location ~* \.(ico|jpg|jpeg|png|gif|svg|js|css|swf|eot|ttf|otf|woff|woff2)\$ {
            add_header Cache-Control "public";
            add_header X-Frame-Options "SAMEORIGIN";
            expires +1y;

            if (!-f \$request_filename) {
                rewrite ^/static/(version\d*/)?(.*)\$ /static.php?resource=\$2 last;
            }
        }
        location ~* \.(zip|gz|gzip|bz2|csv|xml)\$ {
            add_header Cache-Control "no-store";
            add_header X-Frame-Options "SAMEORIGIN";
            expires    off;

            if (!-f \$request_filename) {
            rewrite ^/static/(version\d*/)?(.*)\$ /static.php?resource=\$2 last;
            }
        }
        if (!-f \$request_filename) {
            rewrite ^/static/(version\d*/)?(.*)\$ /static.php?resource=\$2 last;
        }
        add_header X-Frame-Options "SAMEORIGIN";
    }

    location /media/ {
        try_files \$uri \$uri/ /get.php?\$args;

        location ~ ^/media/theme_customization/.*\.xml {
            deny all;
        }

        location ~* \.(ico|jpg|jpeg|png|gif|svg|js|css|swf|eot|ttf|otf|woff|woff2)\$ {
            add_header Cache-Control "public";
            add_header X-Frame-Options "SAMEORIGIN";
            expires +1y;
            try_files \$uri \$uri/ /get.php?\$args;
        }
        location ~* \.(zip|gz|gzip|bz2|csv|xml)\$ {
            add_header Cache-Control "no-store";
            add_header X-Frame-Options "SAMEORIGIN";
            expires    off;
            try_files \$uri \$uri/ /get.php?\$args;
        }
        add_header X-Frame-Options "SAMEORIGIN";
    }

    location /media/customer/ {
        deny all;
    }

    location /media/downloadable/ {
        deny all;
    }

    location /media/import/ {
        deny all;
    }

    location ~ cron\.php {
        deny all;
    }

    location ~ (index|get|static|report|404|503)\.php\$ {
        try_files \$uri =404;
        fastcgi_pass   unix:/var/run/php/php${platform_php}-fpm.sock;

        fastcgi_param  PHP_FLAG  "session.auto_start=off \n suhosin.session.cryptua=off";
        fastcgi_param  PHP_VALUE "memory_limit=256M \n max_execution_time=600";
        fastcgi_read_timeout 600s;
        fastcgi_connect_timeout 600s;
        fastcgi_param  MAGE_MODE \$MAGE_MODE;

        fastcgi_index  index.php;
        fastcgi_param  SCRIPT_FILENAME  \$document_root\$fastcgi_script_name;
        include        fastcgi_params;
    }
}
EOL
echo "Actualizando composer..."
cd .${project_subfolder}
composer install
echo "Actualizando permisos de los archivos..."
chown -R $project_owner:www-data . && chmod -R 777 var/ generated/ pub/
fi
echo "Guardando coniguración nginx..." &&
ln -s /etc/nginx/sites-available/${project_owner}/${platform_domain} /etc/nginx/sites-enabled/${platform_domain}.conf
nginx -t && systemctl restart nginx
fi

echo "¡LISTO!"
echo "Se debe agregar el host \"192.168.0.37 ${platform_domain}\" a la pc local."
# end repeating process

echo "Ingrese ruta a otro directorio para replicar la instalación o 'exit' para terminar (Anterior: \"$project_route\"):"
read project_route
while [ "$project_route" != "exit" ]
do
  echo "Escribe el nombre de la base de datos (el contenido de la carpeta se pisará, anterior: \"$project_bbdd\"):"
  read project_bbdd
  echo "Escribe el nombre del nuevo usuario dueño del proyecto (Anterior: \"$project_owner\"):"
  read project_owner
  if [ "$platform_magento" = "si" ]
  then
  echo "Escribe la NUEVA url del proyecto: (Anterior: \"$platform_url\"):"
  read platform_url
  echo "Escribe dominio del proyecto: (Anterior: \"$platform_domain\"):"
  read platform_domain
  fi

# repeating process
echo "Comienza importación." &&
echo "Creando ruta e inicializando proyecto..." &&
sleep 2 &&
rm -rf $project_route
mkdir -p $project_route &&
cd $project_route
if [ "$sync_repo" = "si" ]
  then
  echo "Inicializando GIT..." &&
  git init &&
  git remote add origin $project_git &&
  git fetch --all &&
  git checkout staging
fi

echo "Extrayendo archivos..." &&
sleep 2 &&
unzip -o $project_zip &&
git status &&

echo "Creando e importando base de datos ${platform_domain}..." &&
sleep 2 &&
echo "drop database $project_bbdd" | mysql -u $bbdd_user -p$bbdd_pass 2> /dev/null
echo "create database $project_bbdd" | mysql -u $bbdd_user -p$bbdd_pass 2> /dev/null
zcat bbdd_backup.sql.gz | mysql -u $bbdd_user -p$bbdd_pass $project_bbdd 2> /dev/null

if [ "$platform_magento" = "si" ]
then
echo "Corrigiendo dominio, emails de clientes y optimizando la bbdd de Magento..." &&
sleep 2 &&
echo "update core_config_data set value = \"${platform_url}\" where path like \"%base_url%\" or path like \"%base_link_url%\"" | mysql -u $bbdd_user -p$bbdd_pass $project_bbdd 2> /dev/null
echo "update sales_order set customer_email = replace(customer_email , \"@\", \"@testk\")" | mysql -u $bbdd_user -p$bbdd_pass $project_bbdd 2> /dev/null
echo "update sales_flat_order set customer_email = replace(customer_email , \"@\", \"@testk\")" | mysql -u $bbdd_user -p$bbdd_pass $project_bbdd 2> /dev/null
echo "update customer_entity set email = replace(email, \"@\", \"@testk\");" | mysql -u $bbdd_user -p$bbdd_pass $project_bbdd 2> /dev/null

echo "Corrigiendo acceso a la base de datos..." &&
mkdir -p /etc/nginx/sites-available/${project_owner}
sleep 2 &&
if [ "$magento_version" = "1" ]
then
cat > .${project_subfolder}/app/etc/local.xml <<EOL
<?xml version="1.0"?>
<config>
  <global>
    <install>
      <date><![CDATA[Wed, 27 Dec 2017 10:57:49 -0200]]></date>
    </install>
    <crypt>
      <key><![CDATA[c02gnol74xfnd2ntburbhqcvt3yvnhxp]]></key>
    </crypt>
    <disable_local_modules>false</disable_local_modules>
    <resources>
      <db>
        <table_prefix><![CDATA[${magento_table_prefix}]]></table_prefix>
      </db>
      <default_setup>
        <connection>
          <host><![CDATA[localhost]]></host>
          <username><![CDATA[${bbdd_user}]]></username>
          <password><![CDATA[${bbdd_pass}]]></password>
          <dbname><![CDATA[${project_bbdd}]]></dbname>
          <initStatements><![CDATA[SET NAMES utf8]]></initStatements>
          <model><![CDATA[mysql4]]></model>
          <type><![CDATA[pdo_mysql]]></type>
          <pdoType><![CDATA[]]></pdoType>
          <active>1</active>
        </connection>
      </default_setup>
    </resources>
    <session_save><![CDATA[files]]></session_save>
  </global>
  <admin>
    <routers>
      <adminhtml>
        <args>
          <frontName><![CDATA[kpanel]]></frontName>
        </args>
      </adminhtml>
    </routers>
  </admin>
</config>
EOL
cat > /etc/nginx/sites-available/${project_owner}/${platform_domain} <<EOL
server {
	listen 80;
	root ${project_route}${project_subfolder};
	index index.php index.html index.htm;

	server_name ${platform_domain};
	access_log /var/log/nginx/${platform_domain}_access.log;
	access_log /var/log/nginx/${platform_domain}_error.log;

	location ^~ /app/                { deny all; }
	location ^~ /includes/           { deny all; }
	location ^~ /lib/                { deny all; }
	location ^~ /media/downloadable/ { deny all; }
	location ^~ /pkginfo/            { deny all; }
	location ^~ /report/config.xml   { deny all; }
	location ^~ /var/                { deny all; }
	location /var/export/            { deny all; }

	location ~ /\. {
		deny  all;
		access_log off;
		log_not_found off;
	}

	location ~*  \.(jpg|jpeg|png|gif|ico)\$ {
		expires 365d;
		log_not_found off;
		access_log off;
	}

	location ~ .php/ { ## Forward paths like /js/index.php/x.js to relevant handler
		rewrite ^(.*.php)/ \$1 last;
    }

	location / {
		index index.html index.php;
		try_files \$uri \$uri/ /index.php?\$query_string;
		expires 30d;
		rewrite /api/rest /api.php?type=rest;
    }

	# pass the PHP scripts to FPM socket
	location ~ \.php\$ {
		fastcgi_pass unix:/var/run/php/php${platform_php}-fpm.sock;
		fastcgi_param MAGE_RUN_TYPE store;
		fastcgi_index index.php;
		include fastcgi.conf;
    }
}
EOL
echo "Actualizando permisos de los archivos..."
cd .${project_subfolder}
chown -R www-data:$project_owner . && chmod -R 777 var/
fi
if [ "$magento_version" = "2" ]
then
cat > .${project_subfolder}/app/etc/env.php <<EOL
<?php
return [
  'backend' => [
    'frontName' => 'kpanel'
  ],
  'crypt' => [
    'key' => 'eeaa9f31a8c5112834f0cc552a6204a8'
  ],
  'db' => [
    'table_prefix' => '${magento_table_prefix}',
    'connection' => [
      'default' => [
        'host' => 'localhost',
        'dbname' => '${project_bbdd}',
        'username' => '${bbdd_user}',
        'password' => '${bbdd_pass}',
        'model' => 'mysql4',
        'engine' => 'innodb',
        'initStatements' => 'SET NAMES utf8;',
        'active' => '1'
      ]
    ]
  ],
  'resource' => [
    'default_setup' => [
      'connection' => 'default'
    ]
  ],
  'x-frame-options' => 'SAMEORIGIN',
  'MAGE_MODE' => 'developer',
  'session' => [
    'save' => 'files'
  ],
  'cache_types' => [
    'config' => 1,
    'layout' => 1,
    'block_html' => 1,
    'collections' => 1,
    'reflection' => 1,
    'db_ddl' => 1,
    'eav' => 1,
    'customer_notification' => 1,
    'config_integration' => 1,
    'config_integration_api' => 1,
    'full_page' => 1,
    'config_webservice' => 1,
    'translate' => 1,
    'compiled_config' => 1,
    'wp_gtm_categories' => 1
  ],
  'install' => [
    'date' => 'Wed, 10 Oct 2018 16:17:12 +0000'
  ],
  'system' => [
    'default' => [
      'dev' => [
        'debug' => [
          'debug_logging' => '0'
        ]
      ]
    ]
  ]
];
EOL
cat > /etc/nginx/sites-available/${project_owner}/${platform_domain} <<EOL
server {
    listen 80;
    server_name ${platform_domain};
    set \$MAGE_ROOT ${project_route}${project_subfolder};
    set \$MAGE_MODE developer;

    root \$MAGE_ROOT/pub;
    index index.php;
    autoindex off;
    charset off;

    add_header 'X-Content-Type-Options' 'nosniff';
    add_header 'X-XSS-Protection' '1; mode=block';

    location /setup {
        root \$MAGE_ROOT;
        location ~ ^/setup/index.php {
            fastcgi_pass   unix:/var/run/php/php${platform_php}-fpm.sock;
            fastcgi_index  index.php;
            fastcgi_param  SCRIPT_FILENAME  \$document_root\$fastcgi_script_name;
            include        fastcgi_params;
        }

        location ~ ^/setup/(?!pub/). {
            deny all;
        }

        location ~ ^/setup/pub/ {
            add_header X-Frame-Options "SAMEORIGIN";
        }
    }

    location /update {
        root \$MAGE_ROOT;

        location ~ ^/update/index.php {
            fastcgi_split_path_info ^(/update/index.php)(/.+)\$;
            fastcgi_pass   unix:/var/run/php/php${platform_php}-fpm.sock;
            fastcgi_index  index.php;
            fastcgi_param  SCRIPT_FILENAME  \$document_root\$fastcgi_script_name;
            fastcgi_param  PATH_INFO        \$fastcgi_path_info;
            include        fastcgi_params;
        }

        # deny everything but index.php
        location ~ ^/update/(?!pub/). {
            deny all;
        }

        location ~ ^/update/pub/ {
            add_header X-Frame-Options "SAMEORIGIN";
        }
    }

    location / {
        try_files \$uri \$uri/ /index.php?\$args;
    }

    location /pub {
        location ~ ^/pub/media/(downloadable|customer|import|theme_customization/.*\.xml) {
            deny all;
        }
        alias \$MAGE_ROOT/pub;
        add_header X-Frame-Options "SAMEORIGIN";
    }

    location /static/ {
        if (\$MAGE_MODE = "production") {
            expires max;
        }
        location ~* \.(ico|jpg|jpeg|png|gif|svg|js|css|swf|eot|ttf|otf|woff|woff2)\$ {
            add_header Cache-Control "public";
            add_header X-Frame-Options "SAMEORIGIN";
            expires +1y;

            if (!-f \$request_filename) {
                rewrite ^/static/(version\d*/)?(.*)\$ /static.php?resource=\$2 last;
            }
        }
        location ~* \.(zip|gz|gzip|bz2|csv|xml)\$ {
            add_header Cache-Control "no-store";
            add_header X-Frame-Options "SAMEORIGIN";
            expires    off;

            if (!-f \$request_filename) {
            rewrite ^/static/(version\d*/)?(.*)\$ /static.php?resource=\$2 last;
            }
        }
        if (!-f \$request_filename) {
            rewrite ^/static/(version\d*/)?(.*)\$ /static.php?resource=\$2 last;
        }
        add_header X-Frame-Options "SAMEORIGIN";
    }

    location /media/ {
        try_files \$uri \$uri/ /get.php?\$args;

        location ~ ^/media/theme_customization/.*\.xml {
            deny all;
        }

        location ~* \.(ico|jpg|jpeg|png|gif|svg|js|css|swf|eot|ttf|otf|woff|woff2)\$ {
            add_header Cache-Control "public";
            add_header X-Frame-Options "SAMEORIGIN";
            expires +1y;
            try_files \$uri \$uri/ /get.php?\$args;
        }
        location ~* \.(zip|gz|gzip|bz2|csv|xml)\$ {
            add_header Cache-Control "no-store";
            add_header X-Frame-Options "SAMEORIGIN";
            expires    off;
            try_files \$uri \$uri/ /get.php?\$args;
        }
        add_header X-Frame-Options "SAMEORIGIN";
    }

    location /media/customer/ {
        deny all;
    }

    location /media/downloadable/ {
        deny all;
    }

    location /media/import/ {
        deny all;
    }

    location ~ cron\.php {
        deny all;
    }

    location ~ (index|get|static|report|404|503)\.php\$ {
        try_files \$uri =404;
        fastcgi_pass   unix:/var/run/php/php${platform_php}-fpm.sock;

        fastcgi_param  PHP_FLAG  "session.auto_start=off \n suhosin.session.cryptua=off";
        fastcgi_param  PHP_VALUE "memory_limit=256M \n max_execution_time=600";
        fastcgi_read_timeout 600s;
        fastcgi_connect_timeout 600s;
        fastcgi_param  MAGE_MODE \$MAGE_MODE;

        fastcgi_index  index.php;
        fastcgi_param  SCRIPT_FILENAME  \$document_root\$fastcgi_script_name;
        include        fastcgi_params;
    }
}
EOL
echo "Actualizando composer..."
cd .${project_subfolder}
composer install
echo "Actualizando permisos de los archivos..."
chown -R $project_owner:www-data . && chmod -R 777 var/ generated/ pub/
fi
echo "Guardando coniguración nginx..." &&
ln -s /etc/nginx/sites-available/${project_owner}/${platform_domain} /etc/nginx/sites-enabled/${platform_domain}.conf
nginx -t && systemctl restart nginx
fi

echo "¡LISTO!"
echo "Se debe agregar el host \"192.168.0.37 ${platform_domain}\" a la pc local."
# end repeating process

  echo "Ingrese ruta a otro directorio para replicar la instalación o 'exit' para terminar (Anterior: \"$project_route\"):"
  read project_route
done

echo "Importador de proyectos por ezeac."
exit
