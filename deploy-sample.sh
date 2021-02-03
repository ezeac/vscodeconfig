rm -rf var/cache var/generation var/di var/view_preprocessed var/report var/page_cache pub/static/_cache pub/static/_requirejs pub/static/adminhtml pub/static/deployed_version.txt pub/static/frontend

php7.2 bin/magento setup:upgrade
php7.2 bin/magento setup:di:compile

php7.2 bin/magento setup:static-content:deploy es_AR es_ES en_US -f

php7.2 bin/magento cache:flush
php7.2 bin/magento cache:enable
php7.2 bin/magento maintenance:disable
php7.2 bin/magento indexer:reindex
sudo chown -R $USER:www-data . && sudo chmod -R 664 . && sudo find . -type d -exec chmod 775 {} \; && sudo chmod u+x,g+x bin/magento && sudo find . -path '*.sh' -exec chmod u+x,g+x {} \;
sudo chmod -R 775 pub/ var/ generated/
php7.2 bin/magento cache:clean
# Restart service php
sudo systemctl restart php7.2-fpm.service
