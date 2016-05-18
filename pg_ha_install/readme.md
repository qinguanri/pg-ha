# pg高可用自动安装

## 执行顺序
------

```
cp -r pg_ha_install /root

cd /root/pg_ha_install
./config.sh 
```

```
./open_port.sh
```

```
./create_repo.sh
```

```
./install_pacemacker.sh
```

```
./install_pg_master.sh
```

```
./install_pg_slave.sh
```

```
./auto_change.sh
```

```
./check_pg.sh
```

