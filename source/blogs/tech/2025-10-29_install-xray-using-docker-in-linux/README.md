# install xray(server)  using docker in a linux


## 安装docker 和 xray镜像，用的第三方镜像
curl -fsSL https://get.docker.com -o get-docker.sh
sh get-docker.sh
docker --version

sudo docker run -d --name xray --network host -v /etc/xray:/etc/xray teddysun/xray
sudo docker ps -a
sudo docker logs xray
sudo docker inspect xray | grep -A 10 Mounts

## 这里的UUID是用在服务端配置文件中的clients:id 项
UUID=$(cat /proc/sys/kernel/random/uuid)
myvpn:4b40b98b-30ca-42b6-b4a0-ae4a8ae108b7
xjp:208c58d9-eb9d-4158-ac03-76baa47f5a0a

mkdir -p /etc/xray
sudo tee /etc/xray/config.json <<EOF
{
  "log": {
    "loglevel": "warning"
  },
  "inbounds": [
    {
      "port": 443,
      "protocol": "vless",
      "settings": {
        "clients": [
          {
            "id": "208c58d9-eb9d-4158-ac03-76baa47f5a0a",
            "flow": "xtls-rprx-vision"
          }
        ],
        "decryption": "none"
      },
      "streamSettings": {
        "network": "tcp",
        "security": "tls",
        "tlsSettings": {
          "certificates": [
            {
              "certificateFile": "/etc/xray/cert.pem",
              "keyFile": "/etc/xray/key.pem"
            }
          ]
        }
      }
    }
  ],
  "outbounds": [
    {
      "protocol": "freedom"
      ,"settings": {
            "domainStrategy": "UseIPv4"
        }
    }
  ]
}
EOF

sudo chmod 644 /etc/xray/config.json

## 证书和自动续期 centos上用yum
sudo apt install certbot -y
## 需要开放80端口进行验证
sudo certbot certonly --standalone -d vpn.chatgptmessagetree.com --non-interactive --agree-tos -m info@chatgptmessagetree.com
### 下面两个操作是有问题的， 因为配置文件中并没有挂载下面的目录，运行时会提示文件找不到或不存在，暂时是把文件拷贝到配置目录处理的这个问题。
sudo ln -sf /etc/letsencrypt/live/vpn.chatgptmessagetree.com/fullchain.pem /etc/xray/cert.pem
sudo ln -sf /etc/letsencrypt/live/vpn.chatgptmessagetree.com/privkey.pem /etc/xray/key.pem
### 下面是用crontab实现证书自动续期，每天中午检查一次(0 12 * * * /usr/bin/certbot renew --quiet && sudo docker restart xray)
sudo crontab -e

sudo docker restart xray
sudo docker logs xray


### 下面是运行不成功时的troubleshooting过程，最终是目录没有正确挂载到docker中，找不到证书文件引起的。
sudo openssl x509 -in /etc/xray/cert.pem -text -noout | head -20
sudo openssl pkey -in /etc/xray/key.pem -text -noout
sudo openssl ec -in /etc/xray/key.pem -check
sudo openssl x509 -noout -pubkey -in /etc/xray/cert.pem | openssl sha256
sudo openssl ec -in /etc/xray/key.pem -pubout | openssl sha256
sudo chmod 644 /etc/xray/cert.pem /etc/xray/key.pem
sudo docker logs xray

sudo grep -A2 "clients" /etc/xray/config.json
sudo vim /etc/xray/config.json
sudo docker restart xray
sudo docker logs xray


# xray 客户端的配置（https://github.com/XTLS/Xray-core 项目地址）目前MAC M1中安装的v2rayU客户端（小米手机禁止安装此种客户端，放弃了）
在项目的客户端列表中选一个，然后到对应的关联项目的realease中直接下载安装包

对于网络下载的程序，MAC中不能正常启动的，需要修改包属性：(sudo xattr -cr /路径/应用名称.app)
sudo xattr -cr /Applications/V2rayU.app

然后在程序界面中配置相关参数：
protocol:服务端配置文件 vless
address:服务器地址和端口
id: 服务端配置文件中的UUID
flow:服务端配置文件中 clients."flow": "xtls-rprx-vision"
network: tcp
security: tls
allowinsecure: 不勾选
serverName: 服务端生成证书时使用的域名

这样基本上就跑起来了， 其他设置后面再慢慢摸索，先用着





