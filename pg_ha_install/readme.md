# PostgreSQL双机热备、高可用自动安装脚本

## 执行顺序
------

(1) 在master和slave主机上都要执行。检查安装环境、配置master、salve的IP

```
cp -r pg_ha_install /root

cd /root/pg_ha_install
./config.sh MASTER_IP=1.2.3.4 SLAVE_IP=1.2.3.5 VIP_PG_MASTER=1.2.3.6 VIP_PG_SLAVE=1.2.3.7 NET=1.2.0.0/16 PG_DIR=/data/postgresql
```

(2) 在master和slave主机上都要执行。打开所需端口

```
./open_port.sh
```

(3) 在master和slave主机上都要执行。创建repo离线安装包

```
./create_repo.sh
```

(4) 在master和slave主机上都要执行。安装pacemaker和pg

```
./install_pacemacker.sh
```

(5) 在master主机上执行。初始化pg master

```
./install_pg_master.sh
```

(6) 在salve主机上执行。初始化pg salve。需要输入postgres密码：postgres

```
./install_pg_slave.sh
```

(7) 在master主机上执行。配置主备自动切换

```
./auto_change.sh
```

(8) 在master或slave主机上执行。大约需要等待30秒后，数据库启动完成，执行以下脚本检查安装是否正确。

```
./check_pg.sh
```

