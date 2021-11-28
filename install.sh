 function install_xray() {
  generate_certificate
}

function generate_certificate() {
  read -rp "请输入你的域名信息(eg: www.wulabing.com):" domain
  cert_sh="/root/cert.sh"
  wget -O cert.sh https://raw.githubusercontent.com/gcp5678/xray/main/cert_dns.sh
  sed -i "s/xxx/${domain}/g" ${cert_sh}
  chmod 755 cert.sh && ./cert.sh
  nginx_install
  certificate_renewal
}

function nginx_install() {
  apt update && apt install nginx -y
  mkdir -p /var/www/website/html
  cd /var/www/website/html/
  git clone https://github.com/gcp5678/webxyar.git
  cd webxyar && unzip -o -d /var/www/website/html xray_web.zip
  mv /var/www/website/html/xray_web/* /var/www/website/html/
  cd /var/www/website/html/ && rm -rf webxyar && rm -rf xray_web

  nginx_conf="/etc/nginx/125125.conf"
  cd /etc/nginx/ && wget -O 125125.conf https://raw.githubusercontent.com/gcp5678/xray/main/125125.conf
  sed -i "s/xxx/${domain}/g" ${nginx_conf}
  xray_install
}

function xray_install() {
  bash -c "$(curl -L https://github.com/XTLS/Xray-install/raw/main/install-release.sh)" @ install
  configure_xray 
}

function configure_xray() {
  cd /usr/local/etc/xray/ && rm -rf config.json && wget -O config.json "https://raw.githubusercontent.com/gcp5678/xray/main/config.json"
  restart_all
}

function restart_all() {
  systemctl enable xray && systemctl enable nginx && systemctl restart xray && systemctl reload nginx
}

function certificate_renewal() {
   cert_renewsh="/etc/ssl/private/cert_renew.sh"
   cd /etc/ssl/private/ && wget -O cert_renew.sh https://raw.githubusercontent.com/gcp5678/xray/main/cert_renew.sh
   sed -i "s/xxx/${domain}/g" ${cert_renewsh}
   chmod 755 /etc/ssl/private/cert_renew.sh
} 

menu() {
  echo -e "—————————————— 安装向导 ——————————————"""
  echo -e "${Green}0.${Font}  安装证书"
  read -rp "请输入数字：" menu_num
  case $menu_num in
  0)
  install_xray
  esac
}
 menu "$@"
