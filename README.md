Creates a single node druid cluster (v0.8.1) with Zookeeper.
All processes are spawned/supervised by supervisord.

`vagrant up`


Once that is up, you should be able to hit the Overlord on:
http://192.168.50.4:8080/console.html

You can hit the coordinator on:
http://192.168.50.4:8081/

Druid Docs
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
