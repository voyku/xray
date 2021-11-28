 function install_xray() {
  generate_certificate
}

function generate_certificate() {
  read -rp "请输入你的域名信息(eg: www.wulabing.com):" domain
  cert_sh="/root/cert.sh"
  wget -O cert.sh https://raw.githubusercontent.com/voyku/xray/main/cert_dns.sh
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

  nginx_conf="/etc/nginx/conf.d/${domain}.conf"
  cd /etc/nginx/conf.d/ && wget -O ${domain}.conf https://raw.githubusercontent.com/voyku/xray/main/125125.conf
  sed -i "s/xxx/${domain}/g" ${nginx_conf}
  print_ok "Nginx 配置 修改"
  systemctl restart nginx
  xray_install
}

function xray_install() {
  bash -c "$(curl -L https://github.com/XTLS/Xray-install/raw/main/install-release.sh)" @ install
  print_ok "Xray 安装"
  configure_xray 
}

function configure_xray() {
  cd /usr/local/etc/xray/ && rm -rf config.json && wget -O config.json "https://raw.githubusercontent.com/voyku/xray/main/config.json"
  print_ok "Xray配置修改"
  restart_all
}

function restart_all() {
  systemctl enable xray && systemctl enable nginx && systemctl restart xray && systemctl reload nginx
  print_ok "Xray和nginx重启成功"
}

function certificate_renewal() {
   cert_renewsh="/etc/ssl/private/cert_renew.sh"
   cd /etc/ssl/private/ && wget -O cert_renew.sh https://raw.githubusercontent.com/voyku/xray/main/cert_renew.sh
   sed -i "s/xxx/${domain}/g" ${cert_renewsh}
   chmod 755 /etc/ssl/private/cert_renew.sh
   echo -e "0 1 1 * *   bash /etc/ssl/private/xray-cert-renew.sh" >> /var/spool/cron/crontabs/root 
   print_ok "已证书自动更新"
   print_ok "vless://b7662d12-d48a-4ab8-8834-9864a01592b3@${domain}:443?flow=xtls-rprx-direct&encryption=none&security=xtls&type=tcp&headerType=none&host=${domain}#${domain}"
}

function print_ok() {
  echo -e "${OK} ${Blue} $1 ${Font}"
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
