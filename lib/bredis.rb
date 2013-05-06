require 'acts_as_hashish'

require 'bredis'
require 'bredis/version'
require 'bredis/bredis'

Hashish.configure {|c| c.redis_connection = Redis.new(:db => 3)}

# WHATS THIS

# a business rule engine that sits inside redis
# uses a pure JSON DSL 
# is pretty damn fast (4000 conditions are evaluated in 0.8 msec and takes only approx 2.5 MB of RAM)
# allows you to search the rules
# can import/export to pure json (file I/O)
# can specify priorities for rules and evaluate the first N matching based on priority
# has a nice UI (not this version)

