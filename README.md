Creates a single node druid cluster (v0.8.1) with Zookeeper.
All processes are spawned/supervised by supervisord.

`vagrant up`

Once that is up, you should be able to hit the Overlord on:
http://192.168.50.4:8080/console.html

You can hit the coordinator on:
http://192.168.50.4:8081/

Control
---

If you need to bounce things, use:

```
sudo service supervisor stop
sudo service supervisor start
```

You may also need to kick mysqld:

```
/etc/init.d/mysqld restart
```






Druid Docs
---
- [Coordinator](http://druid.io/docs/latest/Coordinator.html)
- [All config](http://druid.io/docs/latest/Configuration.html)
- [Tranquility](https://github.com/druid-io/tranquility)
- [Indexing Service](http://druid.io/docs/latest/Indexing-Service.html)
- [Indexing Service Config](http://druid.io/docs/latest/Indexing-Service-Config.html)
- [How to setup HTTP metrics ?](https://groups.google.com/forum/#!topic/druid-development/bgWDDJDg574)
