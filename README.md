Redding Indexer
===============

This project is meant to index Reddit's /all for its top ~50 'hot' posts of each day.

It'll do this by making 4 different requests spread throughout the day, this is so we get a decent sample.
During each request it'll grab the top 50 'hot' posts. It'll store or update posts if they've already been indexed.
Posts are stored into elasticsearch.

Install
-------
1. Install elastic search
2. `$ git clone ...`
3. `$ cd ...`
4. `npm install`

Use
---

1. Start elastic search
2. `$ bin/indexer`

TODO
----

* Optionally, it'll store the comments of posts.

License
-------

MIT
