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
