## DATOS ESPECÍFICOS DEL ENTORNO

# 'Escribe la ruta absoluta en donde estarán los archivos del proyecto (el contenido de la carpeta se pisará):'
project_route="/var/www/html/elauditorm2"

# 'Escribe el nombre de la base de datos (si existe se pisará):'
project_bbdd="elauditorm2"

# 'Escribe el nombre del nuevo usuario dueño del proyecto:'
project_owner="kudos"

# 'Escribe la NUEVA url completa del proyecto:'
platform_url="http://dev.elauditor.com.ar"

# 'Escribe dominio del proyecto:'
platform_domain="dev.elauditor.com.ar"


## DATOS GENERALES DEL PROYECTO 

# 'Escribe la ruta absoluta al comprimido zip del proyecto:' (ejemplo de exportación: mysqldump --quick --single-transaction --lock-tables=false -u magento -pBBDD_password BBDD_name | gzip -9 > bbdd_backup.sql.gz && zip --exclude "*/cache/*" --exclude "*.git/*" --exclude "*var/log/*" --exclude "*import/*" --exclude "*generated/*" --exclude "*pub/static/*" -ru ../fullsite_backup_$(date -I).zip . && rm bbdd_backup.sql.gz)
project_zip="/home/kudos/elauditorm2_backup_2020-08-11.zip"

# 'Escribe la subcarpeta donde se encuentra el proyecto (en caso que la plataforma se haya instalado en una subcarpeta dentro del repo). Ejemplo: ("/tiendalibero"):'
project_subfolder=""

# '¿Realizar vinculación con repositorio? (si/no):'
sync_repo="si"

# 'Escribe la url https del repositorio GIT:'
project_git="https://github.com/kudosestudio/elauditor-m2.git"

# 'Usuario de base de datos:'
bbdd_user="root"

# 'Password de base de datos:'
bbdd_pass="Developers2017"

# '¿El proyecto a importar es MAGENTO? (si/no):'
platform_magento="si"

# 'Versión de magento (1/2):'
magento_version="2"

# '¿El proyecto a importar es WORDPRESS? (si/no):'
platform_wordpress="no"

# 'Escribe la url ORIGINAL completa del proyecto:'
platform_old_url="http://carlos.elauditor.com.ar"

# 'Versión PHP del proyecto: (5.6/7.0/7.1/7.2):'
platform_php="7.2"

# 'Ingrese el prefijo de las tablas (dejar vacío en caso que no corresponda):'
table_prefix=""


