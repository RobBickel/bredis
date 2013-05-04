require 'acts_as_hashish'
require 'json'

Hashish.configure {|c| c.redis_connection = Redis.new(:db => 3)}

# TODO

# redis representation of rules
# ruby client that can create rules and evaluate rules (pure JSON input, output)
# java client that can create rules and evaluate rules (pure JSON input, output)

# the engine
module Bredis

  # imports many rules into the engine from a one or many JSON rules or JSON file
  def self.import(json)
    
  end
  
  def self.evaluate(params, options = {})
    options[:match] ||= 1
    result = []
    matches = 0
    BusinessRule.hashish_list(:filters => {'o' => '?'}).each do |rule|
      break if matches >= options[:match]
      if rule['lhs'] or BusinessRule.evaluate(BusinessRule.hashish_find(rule['lhs_id']), params)
        matches += 1
        result << (rule['rhs'] or BusinessRule.evaluate(BusinessRule.hashish_find(rule['rhs_id']), params)) # if rule['rule_type'] == :inferred
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
      puts "evaluating #{exp.inspect}"
      if exp['lhs_id']
        puts "=>"
        lhs = evaluate(BusinessRule.hashish_find(exp['lhs_id']), params)
      elsif params[exp['lhs']]
        puts "P"
        lhs = params[exp['lhs']]
      else
        lhs = exp['lhs']
      end
      op = exp['op']
      if exp['rhs_id']
        rhs = evaluate(BusinessRule.hashish_find(exp['rhs_id']), params)
      elsif params[exp['rhs']]
        rhs = params[exp['rhs']]
      else
        rhs = exp['rhs']
      end
      operate(op, lhs, rhs)
    end

    def self.operate(op, lhs, rhs)
      puts "#{lhs} #{op} #{rhs}"
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
                       'id' => '1',
                       'op' => '?',
                       'lhs' => {
                         'id' => '2',
                         'lhs' => '$product', 
                         'op' => '==', 
                         'rhs' => 'shoes'
                       }, 
                       'rhs' => {
                         'id' => '3',
                         'lhs' => '$discount', 
                         'op' => '=',
                         'rhs' => '500'
                       }}.to_json)
b = Bredis::BusinessRule.new({
                       'priority' => nil,
                       'id' => '4',
                       'op' => '?',
                       'lhs' => {
                         'id' => '5',
                         'lhs' => '$product', 
                         'op' => '==', 
                         'rhs' => 'clothes'
                       }, 
                       'rhs' => {
                         'id' => '6',
                         'lhs' => '$discount', 
                         'op' => '=',
                         'rhs' => '200'
                       }}.to_json)
                       

# Bredis.evaluate({'$product' => 'shoes'})

