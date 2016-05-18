# pg高可用自动安装

## 执行顺序
------

(1)

```
cp -r pg_ha_install /root

cd /root/pg_ha_install
./config.sh 
```

(2)

```
./open_port.sh
```

(3)

```
./create_repo.sh
```

(4)

```
./install_pacemacker.sh
```

(5)

```
./install_pg_master.sh
```

(6)

```
./install_pg_slave.sh
```

(7)

```
./auto_change.sh
```

(8)

```
./check_pg.sh
```

