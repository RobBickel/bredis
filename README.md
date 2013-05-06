# BREdis [![Build Status](https://travis-ci.org/saturnine/bredis.png?branch=master)](https://travis-ci.org/saturnine/bredis) [![Coverage Status](https://coveralls.io/repos/saturnine/bredis/badge.png?branch=master)](https://coveralls.io/r/saturnine/bredis)

## What is BREdis?

A Business Rule Engine that sits inside redis

## Goals

* uses a pure JSON DSL 
* is pretty damn fast (4000 conditions are evaluated in 8 msec and takes only approx 2.5 MB of RAM)
* allows you to search the rules
* can import/export to pure json (file I/O)
* can specify priorities for rules and evaluate the first N matching, based on priority
* has a nice UI (not this version)

## Copyright

Copyright (c) 2012-2013 Schubert Cardozo. See LICENSE for further details.