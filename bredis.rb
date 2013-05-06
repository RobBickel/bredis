# WHATS THIS

# a business rule engine that sits inside redis
# uses a pure JSON DSL 
# is pretty damn fast (4000 conditions are evaluated in 0.8 msec and takes only approx 2.5 MB of RAM)
# allows you to search the rules
# can import/export to pure json (file I/O)
# can specify priorities for rules and evaluate the first N matching based on priority
# has a nice UI (not this version)

require 'acts_as_hashish'
require 'json'
require 'benchmark'

Hashish.configure {|c| c.redis_connection = Redis.new(:db => 3)}


# the engine
module Bredis

  # search '$product' => 'shoes', '$price' => (0..500).to_a
  def self.search(query_hash, options = {})
    filters = {}
    query_hash.each do |key, value|
      filters.merge!('l' => key, 'r' => value)
    end
    options.merge(:filters => filters)
    Bredis::BusinessRule.hashish_list(options)
  end

  # imports many rules into the engine from a one or many JSON rules or JSON file
  def self.import(json)
    
  end
  
  def self.evaluate(params = {}, max_match = 1)
    result = []
    matches = 0
    BusinessRule.hashish_list(:filters => {'o' => '?'}).each do |rule|
      break if matches >= max_match
      # trickly because of logical operators in the rule
      if (rule['lhs_id'] and BusinessRule.evaluate(BusinessRule.hashish_find(rule['lhs_id']), params)) or rule['lhs']
        matches += 1
        result << (rule['rhs_id'] and BusinessRule.evaluate(BusinessRule.hashish_find(rule['rhs_id']), params)) or rule['rhs'] # (rule['rhs'] or BusinessRule.evaluate(BusinessRule.hashish_find(rule['rhs_id']), params)) # if rule['rule_type'] == :inferred
      end
    end
    return result
  end

  # encapsulates a single rule
  class BusinessRule
    attr_accessor :priority, :prefix
    acts_as_hashish(:key => 'id', :indexes => {'l'=> 'lhs', 'r' => 'rhs', 'o' => 'op'})

    def initialize(json)
      rule = JSON.parse(json)
      @priority = rule['priority']
      @id = rule['id']
      push(rule)
    end
    
    # evaluate single rule
    def self.evaluate(exp, params)
      puts "EVAL : #{exp.inspect}"
      if !exp['lhs_id'].nil?
        lhs = evaluate(BusinessRule.hashish_find(exp['lhs_id']), params)
      elsif params[exp['lhs']]
        lhs = params[exp['lhs']]
      else
        lhs = exp['lhs']
      end
      op = exp['op']
      if !exp['rhs_id'].nil?
        rhs = evaluate(BusinessRule.hashish_find(exp['rhs_id']), params)
      elsif params[exp['rhs']]
        rhs = params[exp['rhs']]
      else
        rhs = exp['rhs']
      end
      operate(op, lhs, rhs)
    end

    def self.operate(op, lhs, rhs)
      puts "\t#{lhs} #{op} #{rhs}"
      case op 
      when '='
        {lhs => rhs}
      else
        lhs.send(op, rhs)
      end
    end
    
    def delete
      hashish_list(:filters => {'rule_id' => @id}).each do |h|
        hashish_delete(h['id'])
      end
    end
    
    def push(exp, id = nil)
      id ||= exp['id']
      lhs = lhs_id = rhs = rhs_id = nil
      if exp['lhs'].is_a?(Hash)
        lhs_id = exp['lhs']['id']
        push(exp['lhs'])
      else
        lhs = exp['lhs']
      end
      op = exp['op']
      if exp['rhs'].is_a?(Hash)
        rhs_id = exp['rhs']['id']
        push(exp['rhs'])
      else
        rhs = exp['rhs']
      end
      BusinessRule.hashish_insert({'id' => id, 'lhs' => lhs, 'op' => op, 'rhs' => rhs, 'lhs_id' => lhs_id, 'rhs_id' => rhs_id, 'rule_id' => @id})
    end
    
  end
end
# {'id' => '1', 'lhs_id' => '2', 'op' => '?', 'rhs_id' => '3', 'rule_id' => '1'}
# {'id' => '2', 'lhs' => '$product', 'op' => '==', 'rhs' => 'shoes', 'rule_id' => '1'}
# {'id' => '3', 'lhs' => '$discount', 'op' => '=', 'rhs' => '500', 'rule_id' => '1'}

# {'id' => '4', 'lhs_id' => '5', 'op' => '?', 'rhs_id' => '6', 'rule_id' => '4'}
# {'id' => '5', 'lhs' => '$product', 'op' => '==', 'rhs' => 'clothes', 'rule_id' => '4'}
# {'id' => '6', 'lhs' => '$discount', 'op' => '=', 'rhs' => '200', 'rule_id' => '4'}

# example for discount on clothes and shoes

a = Bredis::BusinessRule.new({
                               'priority' => nil,
                               'id' => 1,
                               'op' => '?',
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
                               }}.to_json)
b = Bredis::BusinessRule.new({
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
                               }}.to_json)


# RESULT = Bredis.evaluate({'$product' => 'shoes', '$fare' => 500})


def benchmark(n)
  Hashish.redis_connection.flushdb
  mb1 = Hashish.redis_connection.info['used_memory_human']
  # create N rules
  n.times do 
    Bredis::BusinessRule.new({'id' => next_seq, 'op' => '?', 'lhs' => random_expression, 'rhs' => {'id' => next_seq, 'lhs' => '$result', 'rhs' => random_expression, 'op' => '='}}.to_json)
  end
  result = nil
  t = Benchmark.realtime do
    result = Bredis.evaluate({}, n)
  end
  rules = Bredis::BusinessRule.hashish_list(:filters => {'o' => '?'}, :page_size => 0)
  mb2 = Hashish.redis_connection.info['used_memory_human']
  puts "Evaluated #{Bredis::BusinessRule.hashish_length} expressions among #{rules.length} rules in #{t} seconds"
  puts "RES = #{result.inspect}"
  puts "MB = #{mb2.to_f - mb1.to_f}"
end

def random_expression
  case rand(3) 
  when 0
    true
  when 1
    false
  when 2
    lhs = random_expression
    rhs = random_expression
    op = (rand(2) == 1 ? '|' : '&')
    x = next_seq
    return {'lhs' => lhs, 'rhs' => rhs, 'op' => op, 'id' => x}
  end
end

def next_seq
  Hashish.redis_connection.incr('SEQ').to_i
end
