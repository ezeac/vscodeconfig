
#cd /var/www/html/parz.com/http/
#mysqldump --quick --single-transaction --lock-tables=false -u parz_prod -p'}X12G^&Fe' -h parzdev.cj0eeto88czd.us-east-2.rds.amazonaws.com parz_prod | gzip -9 > bbdd_backup_$(date -I).sql.gz && zip --exclude "*cache/*" --exclude "*.git/*" --exclude "*var/log/*" --exclude "*import/*" --exclude "*generated/*" --exclude "*pub/static/*" -ru ../fullsite_parzprod_$(date -I).zip .
#rm bbdd_backup_$(date -I).sql.gz
#exit
ssh -t -i ~/key-parz centos@18.224.117.22 'cd /var/www/html/parz.com/http/; mysqldump --quick --single-transaction --lock-tables=false -u parz_prod -p"}X12G^&Fe" -h parzdev.cj0eeto88czd.us-east-2.rds.amazonaws.com parz_prod | gzip -9 > bbdd_backup_$(date -I).sql.gz && zip --exclude "*cache/*" --exclude "*.git/*" --exclude "*var/log/*" --exclude "*import/*" --exclude "*generated/*" --exclude "*pub/static/*" -ru ../fullsite_parzprod_$(date -I).zip .; rm bbdd_backup_$(date -I).sql.gz'

# sshparzstg
# cd /var/www/html/parz
# scp -i ~/key-parz centos@18.224.117.22:/var/www/html/parz.com/fullsite_parzprod_$(date -I).zip .'
# unzip -p fullsite_parzprod_$(date -I).zip bbdd_backup_$(date -I).sql.gz > bbdd_backup_$(date -I).sql.gz'

ssh -t -p32241 kudos@74.222.3.233 'cd /var/www/html/parz; scp -i ~/key-parz centos@18.224.117.22:/var/www/html/parz.com/fullsite_parzprod_$(date -I).zip . && unzip -p fullsite_parzprod_$(date -I).zip bbdd_backup_$(date -I).sql.gz > bbdd_backup_$(date -I).sql.gz'

# echo "drop database parz; create database parz;" | mysql -uroot -pDevelopers2017 parz
# pv bbdd_backup_$(date -I).sql.gz | zcat | mysql -u root -pDevelopers2017 parz
# echo 'update sales_order set customer_email = replace(customer_email , "@", "@testk") where customer_email NOT LIKE "%kudosestudio.com%";' | mysql -u root -pDevelopers2017 parz
# echo 'update sales_flat_order set customer_email = replace(customer_email , "@", "@testk") where customer_email NOT LIKE "%kudosestudio.com%";' | mysql -u root -pDevelopers2017 parz
# echo 'update customer_entity set email = replace(email, "@", "@testk") where email NOT LIKE "%kudosestudio.com%";' | mysql -u root -pDevelopers2017 parz

ssh -t -p32241 kudos@74.222.3.233 'echo "drop database parz; create database parz;" | mysql -uroot -pDevelopers2017 parz'
ssh -t -p32241 kudos@74.222.3.233 'cd /var/www/html/parz && pv bbdd_backup_$(date -I).sql.gz | zcat | mysql -u root -pDevelopers2017 parz'
ssh -t -p32241 kudos@74.222.3.233 'echo '"'"'update sales_order set customer_email = replace(customer_email , "@", "@testk") where customer_email NOT LIKE "%kudosestudio.com%";'"'"' | mysql -u root -pDevelopers2017 parz'
ssh -t -p32241 kudos@74.222.3.233 'echo '"'"'update sales_flat_order set customer_email = replace(customer_email , "@", "@testk") where customer_email NOT LIKE "%kudosestudio.com%";'"'"' | mysql -u root -pDevelopers2017 parz'
ssh -t -p32241 kudos@74.222.3.233 'echo '"'"'update customer_entity set email = replace(email, "@", "@testk") where email NOT LIKE "%kudosestudio.com%";'"'"' | mysql -u root -pDevelopers2017 parz'

ssh -t -p32241 kudos@74.222.3.233 'echo '"'"'update core_config_data set value = "TEST-a1274c4a-c228-4809-bb34-317a9cd38d21" where path like "payment_mercadopago_custom_checkout_public_key"; update core_config_data set value = "TEST-1305636485428365-050718-901be2be3d7e2abbe2317d790b7b82e6-344615524" where path like "payment_mercadopago_custom_checkout_access_token";'"'"' | mysql -u root -pDevelopers2017 parz'

ssh -t -p32241 kudos@74.222.3.233 'echo '"'"'update core_config_data set value = "https://devm.parz.com/" where path like "%base_url%" or path like "%base_link_url%";'"'"' | mysql -u root -pDevelopers2017 parz'
ssh -t -p32241 kudos@74.222.3.233 'echo '"'"'update core_config_data set value = "https://devm.parz.com/" where path like "web_secure_base_url" or path like "web_unsecure_base_url";'"'"' | mysql -u root -pDevelopers2017 parz'
ssh -t -p32241 kudos@74.222.3.233 'echo '"'"'update core_config_data set value = "https://devm.parz.com/" where path like "web_secure_base_link_url" or path like "web_unsecure_base_link_url";'"'"' | mysql -u root -pDevelopers2017 parz'
ssh -t -p32241 kudos@74.222.3.233 'echo '"'"'update core_config_data set value = "https://devm.parz.com/skin/" where path like "web_secure_base_skin_url" or path like "web_unsecure_base_skin_url";'"'"' | mysql -u root -pDevelopers2017 parz'
ssh -t -p32241 kudos@74.222.3.233 'echo '"'"'update core_config_data set value = "https://devm.parz.com/media/" where path like "web_secure_base_media_url" or path like "web_unsecure_base_media_url";'"'"' | mysql -u root -pDevelopers2017 parz'
ssh -t -p32241 kudos@74.222.3.233 'echo '"'"'update core_config_data set value = "https://devm.parz.com/js/" where path like "web_secure_base_js_url" or path like "web_unsecure_base_js_url";'"'"' | mysql -u root -pDevelopers2017 parz'
ssh -t -p32241 kudos@74.222.3.233 'echo '"'"'update core_config_data set value = NULL where path like "web_cookie_cookie_domain" or path like "web_cookie_cookie_path";'"'"' | mysql -u root -pDevelopers2017 parz'
ssh -t -p32241 kudos@74.222.3.233 'echo '"'"'update core_config_data set value = "https://dev.parz.com/" where path like "kudos_pwassets_general_base_url";'"'"' | mysql -u root -pDevelopers2017 parz'
ssh -t -p32241 kudos@74.222.3.233 'echo '"'"'update core_config_data set value = "AIzaSyBAWKJDrFcLBDn9HqYs35fbXDHLB4fKeQ4" where path like "kudos_pwassets_general_gapi_geoloc_key" or path like "kudos_pwassets_general_gapi_geocod_key";'"'"' | mysql -u root -pDevelopers2017 parz'


ssh -t -p32241 kudos@74.222.3.233 'cd /var/www/html/parz/parz_magento/ && rm -rf var/cache/* && rm -rf var/session/*'
ssh -t -p32241 kudos@74.222.3.233 'cd /var/www/html/parz/parz_pwa/magento1-vsbridge/node-app/src && bash reindex-sample.sh'
