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
