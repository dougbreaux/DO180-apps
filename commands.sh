# guided 4
podman run -d --name official-httpd -p 8180:80 quay.io/redhattraining/httpd-parent
podman exec -it official-httpd /bin/bash
podman commit -a doug official-httpd do180-custom-httpd

source /usr/local/etc/ocp4.config 
podman tag do180-custom-httpd quay.io/${RHT_OCP4_QUAY_USER}/do180-custom-httpd:v1.0
read -s QUAY_PASS
podman login quay.io -u breauxibm -p ${QUAY_PASS}
podman push quay.io/${RHT_OCP4_QUAY_USER}/do180-custom-httpd:v1.0

podman pull quay.io/breauxibm/do180-custom-httpd:v1.0
podman run -d --name test-httpd -p 8280:80 quay.io/breauxibm/do180-custom-httpd:v1.0
curl 127.0.0.1:8280/do180.html

# lab 4
lab image-review start
podman pull quay.io/redhattraining/nginx:1.17
podman run --name official-nginx -d -p 8080:80 quay.io/redhattraining/nginx:1.17
podman ps

podman exec -it official-nginx /bin/bash
echo "DO180" > /usr/share/nginx/html/index.html
curl http://localhost:8080

podman stop official-nginx 
podman commit -a doug official-nginx do180/mynginx:v1.0-SNAPSHOT
podman run --name official-nginx-dev -d -p 8080:80 do180/mynginx:v1.0-SNAPSHOT
podman stop official-nginx-dev 
podman commit -a doug official-nginx-dev do180/mynginx:v1.0

podman rmi -f do180/mynginx:v1.0-SNAPSHOT

podman run -d --name my-nginx -p 8280:80 do180/mynginx:v1.0

# must have committed wrong version, lost the edit
podman exec -it my-nginx /bin/bash
curl http://localhost:8280

# redo steps
podman stop my-nginx
podman commit -a doug my-nginx do180/mynginx:v1.1
podman images
podman rmi -f do180/mynginx:v1.0
podman tag do180/mynginx:v1.1 do180/mynginx:v1.0
podman images
podman rmi -f do180/mynginx:v1.1
podman rm -a
podman ps -a
podman run -d --name my-nginx -p 8280:80 do180/mynginx:v1.0
curl http://localhost:8280
lab image-review grade
podman run --name official-nginx -d -p 8080:80 quay.io/redhattraining/nginx:1.17
podman stop official-nginx 
lab image-review grade

# guided 5
podman build --layers=false -t do180/apache .
podman images
podman run --name lab-apache -d -p 10080:80 do180/apache
podman ps
curl 127.0.0.1:10080

# lab 5
vi Containerfile 
podman build --layers=false -t do180/apache .
podman images
podman tag do180/apache do180/custom-apache
podman images
podman rmi do180/apache
podman images
podman run -d --name containerfile -p 20080:8080 do180/custom-apache
curl http://localhost:20080
lab dockerfile-review grade
lab dockerfile-review finish

# guided 6
source /usr/local/etc/ocp4.config 
oc login -u ${RHT_OCP4_DEV_USER} -p ${RHT_OCP4_DEV_PASSWORD} ${RHT_OCP4_MASTER_API}
oc new-project ${RHT_OCP4_DEV_USER}-mysql-openshift
oc new-app --template=mysql-persistent -p MYSQL_USER=user1 -p MYSQL_PASSWORD=mypa55 -p MYSQL_DATABASE=testdb -p MYSQL_ROOT_PASSWORD=r00tpa55 -p VOLUME_CAPACITY=10Gi

oc status
oc get pods
oc get svc
oc describe svc mysql
oc get pvc
oc describe pvc mysql

oc port-forward mysql-1-kwl2t 3306:3306
mysql -uuser1 -pmypa55 --protocol tcp -h 127.0.0.1
oc delete project tzpfpb-mysql-openshift 

# guided 6 route
lab-configure
source /usr/local/etc/ocp4.config 
oc login -u ${RHT_OCP4_DEV_USER} -p ${RHT_OCP4_DEV_PASSWORD} ${RHT_OCP4_MASTER_API}
lab openshift-routes start

oc new-project ${RHT_OCP4_DEV_USER}-route
oc new-app --docker-image=quay.io/redhattraining/php-hello-dockerfile --name php-helloworld
oc status
oc get pods -w
oc describe svc php-helloworld 
oc expose svc php-helloworld 
oc describe route
curl http://php-helloworld-tzpfpb-route.apps.na46a.prod.ole.redhat.com
curl http://php-helloworld-${RHT_OCP4_DEV_USER}-route.${RHT_OCP4_WILDCARD_DOMAIN}
oc delete route php-helloworld 
oc expose svc php-helloworld --name ${RHT_OCP4_DEV_USER}-xyz
oc describe route
curl http://${RHT_OCP4_DEV_USER}-xyz-${RHT_OCP4_DEV_USER}-route.${RHT_OCP4_WILDCARD_DOMAIN}
lab openshift-routes finish

# guided 6 s2i
oc get is -n openshift
lab openshift-s2i start
git checkout -b s2i
git push -u origin s2i
vi php-helloworld/index.php 
oc new-project ${RHT_OCP4_DEV_USER}-s2i
oc new-app php:7.3 --name=php-helloworld https://github.com/${RHT_OCP4_GITHUB_USER}/DO180-apps#s2i --context-dir php-helloworld
oc logs -f php-helloworld-1-build 
oc describe deployment php-helloworld 
oc expose service php-helloworld --name ${RHT_OCP4_DEV_USER}-helloworld
oc get route tzpfpb-helloworld -o jsonpath='{..spec.host}{"\n"}'
curl http://tzpfpb-helloworld-tzpfpb-s2i.apps.na46a.prod.ole.redhat.com
cd DO180-apps/php-helloworld/
vi index.php
git add index.php
git commit -m "changed index"
git push
oc start-build php-helloworld 
oc logs -f php-helloworld-2-build 
oc get pods
curl http://tzpfpb-helloworld-tzpfpb-s2i.apps.na46a.prod.ole.redhat.com


