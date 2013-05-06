require 'acts_as_hashish'

Hashish.configure {|c| c.redis_connection = Redis.new(:db => 3)}

require 'bredis'
require 'bredis/version'
require 'bredis/operation'
require 'bredis/business_rule'
require 'bredis/bredis'
