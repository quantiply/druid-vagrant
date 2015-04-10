Creates a single node druid cluster (v0.6.160) with Zookeeper.

`vagrant up`

All processes are spawned/supervised by supervisord.

Docs
---
- [Coordinator](http://druid.io/docs/latest/Coordinator.html)
- [All config](http://druid.io/docs/latest/Configuration.html)
- [How to setup HTTP metrics ?](https://groups.google.com/forum/#!topic/druid-development/bgWDDJDg574)
- [Tranquility](https://github.com/metamx/tranquility)
- [Indexing Service](http://druid.io/docs/latest/Indexing-Service.html)
- [Indexing Service Config](http://druid.io/docs/latest/Indexing-Service-Config.html)
- a

Benchmark
---
Blog Post
- http://druid.io/blog/2012/01/19/scaling-the-druid-data-store.html
- http://druid.io/blog/2014/03/17/benchmarking-druid.html

[Github repo](https://github.com/druid-io/druid-benchmark)

Cluster Setup
---
https://github.com/druid-io/whirr/tree/trunk/services/druid/src/main/resources/functions
http://druid.io/docs/latest/Booting-a-production-cluster.html


Coordinator
---
Console [http://192.168.50.4:8082](http://192.168.50.4:8082)

REST API

    curl -s localhost:8082/info/cluster | python -m json.tool
    curl -s localhost:8082/info/segments | python -m json.tool
    curl -s localhost:8082/info/servers?full | python -m json.tool
    curl -s localhost:8082/info/rules | python -m json.tool
    curl -s localhost:8082/info/datasources | python -m json.tool
    curl -s localhost:8082/info/segments?full | ruby -ryaml -rjson -e 'puts YAML.dump(JSON.parse(STDIN.read))'


Indexing 
---

Overlord Console (Bug : it is labelled "Coordinator Console")

[http://192.168.50.4:8087/console.html](http://192.168.50.4:8087/console.html)

Running the wikipedia example
---

Batch Task

    curl -X 'POST' -H 'Content-Type:application/json' \
            192.168.50.4:8087/druid/indexer/v1/task \
            -d @/vagrant/lab/examples/indexing/wikipedia_index_task.json

Realtime Task

    curl -X 'POST' -H 'Content-Type:application/json' \
        192.168.50.4:8087/druid/indexer/v1/task \
        -d @/vagrant/lab/examples/indexing/wikipedia_realtime_task.json

Query

    curl -s -X POST  -H 'Content-type: application/json' \
        192.168.50.4:8080/druid/v2/ \
        -d @/vagrant/lab/examples/wikipedia/query.body \
            | ruby -ryaml -rjson -e 'puts YAML.dump(JSON.parse(STDIN.read))' \
                | more
                
Wait for 15 mins and then see how many edits were made to "articles" namespace

    curl -s -X POST  -H 'Content-type: application/json' \
        192.168.50.4:8080/druid/v2/ \
        -d @/vagrant/lab/examples/wikipedia/totals_for_articles.body \
            | ruby -ryaml -rjson -e 'puts YAML.dump(JSON.parse(STDIN.read))' \
                | more
                

Another one ... get the totals for all namespaces

    curl -s -X POST  -H 'Content-type: application/json' \
        192.168.50.4:8080/druid/v2/ \
        -d @/vagrant/lab/examples/wikipedia/totals_by_ns.body \
            | ruby -ryaml -rjson -e 'puts YAML.dump(JSON.parse(STDIN.read))' \
                | more

curl -s -X POST  -H 'Content-type: application/json' http://192.168.50.4:8087/druid/indexer/v1/task/index_realtime_test1234_2015-01-24T21:00:00.000-08:00_0_0_bjkkcnmm/shutdown


Tranquility
---

Notes from https://groups.google.com/forum/#!msg/druid-development/eIiuSS-fM8I/SioYYGxMxIQJ


1.  MM runtime.properties must have `druid.selectors.indexing.serviceName=druid:prod:overlord` and overlord must have  `druid.service=druid/prod/overlord`
2. For druid dimension and aggregate names must be in lower case. (In tranquility client). (Convert incoming string message to lower case)
3. Timestamp of event must be within windowPeriod.
4. Tranquility client : `.timestampSpec(new TimestampSpec("tstamp", "auto"))`  must have auto as format.
5. windowPeriod

        .tuning(ClusteredBeamTuning.create(Granularity.HOUR, new Period("PT0M"), new Period("PT60M"), 1, 1))
Here PT60M is the windowPeriod. PT2Y  (year) format is not supported. This will cause your task to start and kill. Once the task is killed (or shutdown) druid will delete the logs for default settings. (this could have been avoided).

6. All MMs have:  `druid.indexer.task.chathandler.type=announce` . This is necessary to enable announcing of tasks in service discovery, which tranquility needs in order to find them. You should see something with the phrase "Announcing service" in your tasks logs, that should look like this:
        
        Announcing service[DruidNode{serviceName='druid:firehose:offer_impressions_test_3-04-0000-0001', host='a.b.c.d', port=xxxx}]
Ref : https://groups.google.com/d/msg/druid-development/7g8AYIokK40/Lv1aUefaS2oJ
7. All MMs have :  `druid.publish.type=db` . 
After a real-time node completes building a segment after the window period, what does it do with it? For true handoff to occur, this should be set to "db".

8.druid.indexer.storage.type=db
That setting will switch the overlord to storing task metadata in your mysql database instead of in memory, so it can persist across overlord restarts. The default in-memory task storage gets wiped every time you restart the overlord, which will lead tranquility to look for a task that the overlord doesn't know about.
(https://groups.google.com/d/msg/druid-development/9g4lUylT4KI/kL2k6axMCu8J)
8. druid.discovery.curator.path=/prod/discovery is present in all nodes except historical.


How does realtime ingest handle MM/overlord restarts / upgrade ?
---
https://groups.google.com/forum/#!topic/druid-development/__qjeLrbQwA

S3 Deep storage
---
How to configure ? https://groups.google.com/forum/#!searchin/druid-development/s3/druid-development/dQTTtpYEriQ/YSJLox2oEwUJ
https://groups.google.com/forum/#!searchin/druid-development/s3/druid-development/FewT7L0nOdM/TsC8MOlJLI8J
https://groups.google.com/forum/#!searchin/druid-development/s3/druid-development/RCQlyzzBWnU/CSLyRrf2CcQJ


Multitenancy
---
https://groups.google.com/forum/#!searchin/druid-development/tranquility$20$2B$20s3/druid-development/pIcLauKNnm0/F9SYKWQg_WcJ
