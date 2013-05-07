# BREdis [![Build Status](https://travis-ci.org/saturnine/bredis.png?branch=master)](https://travis-ci.org/saturnine/bredis) [![Coverage Status](https://coveralls.io/repos/saturnine/bredis/badge.png?branch=master)](https://coveralls.io/r/saturnine/bredis)

## What is BREdis?

A Business Rule Engine that sits inside redis

## How do I install it?

`gem install bredis`

or in your `Gemfile`

```ruby
gem 'bredis'
```

Make sure your redis server is running! Redis configuration is outside the scope of this README, but
check out the [Redis documentation](http://redis.io/documentation).

## Usage

```ruby
require 'bredis'

$redis = Redis.new(:db => 3)
product_discount_rules = Bredis::RuleSet.new('product_discount_rules', $redis)

product_discount_rules << {
  'priority' => nil,
  'id' => 1,
  'op			 ' => '?',
  'lhs' => {
    'id' => 2,
    'lhs' => '$product', 
    'op' => '==', 
    'rhs' => 'shoes'
  }, 
  'rhs' => {
    'id' => 3,
    'lhs' => '$discount', 
    'op' => '=',
    'rhs' => {
      'id' => 7,
      'lhs' =>'$fare',
      'op' => '/',
      'rhs' => 2}
  }
}

product_discount_rules << {
  'priority' => nil,
  'id' => 4,
  'op' => '?',
  'lhs' => {
    'id' => 5,
    'lhs' => '$product', 
    'op' => '==', 
    'rhs' => 'clothes'
  }, 
  'rhs' => {
    'id' => 6,
    'lhs' => '$discount', 
    'op' => '=',
    'rhs' => 200
  }
}

product_discount_rules.evalutate({'$product' => 'shoes'})

```

## Goals

* uses a pure JSON DSL 
* is pretty damn fast (4000 conditions are evaluated in 8 msec and takes only approx 2.5 MB of RAM)
* allows you to search the rules
* can import/export to pure json (file I/O)
* can specify priorities for rules and evaluate the first N matching, based on priority
* has a nice UI (not this version)

## Copyright

Copyright (c) 2012-2013 Schubert Cardozo. See LICENSE for further details.
