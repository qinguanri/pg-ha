# pg高可用自动安装

## 执行顺序
------

(1) 检查安装环境、配置master、salve的IP

```
cp -r pg_ha_install /root

cd /root/pg_ha_install
./config.sh MASTER_IP=1.2.3.4 SLAVE_IP=1.2.3.5 VIP_PG_MASTER=1.2.3.6 VIP_PG_SLAVE=1.2.3.7 NET=1.2.0.0/16 PG_DIR=/data/postgresql
```

(2) 打开所需端口

```
./open_port.sh
```

(3) 创建repo离线安装包

```
./create_repo.sh
```

(4) 安装pacemaker和pg

```
./install_pacemacker.sh
```

(5) 初始化pg master

```
./install_pg_master.sh
```

(6) 初始化pg salve

```
./install_pg_slave.sh
```

(7) 配置主备自动切换

```
./auto_change.sh
```

(8) 检查安装是否正确

```
./check_pg.sh
```

