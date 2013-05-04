require 'acts_as_hashish'
require 'json'

Hashish.configure {|c| c.redis_connection = Redis.new(:db => 3)}

# TODO

# redis representation of rules
# ruby client that can create rules and evaluate rules (pure JSON input, output)
# java client that can create rules and evaluate rules (pure JSON input, output)

# the engine
class Bredis

  # imports many rules into the engine from a one or many JSON rules or JSON file
  def self.import(json)
    
  end
  
  def self.evaluate(rules, params, options = {})
    options[:match] ||= 1
    result = []
    matches = 0
    rules.sort_by(:priority).each do |rule|
      break if matches >= options[:match]
      if rule.evaluate(params)
        matches += 1
        result << rule.consequence if rule.rule_type == :inferred
      end
    end
    return result
  end
end

# encapsulates a single rule
class BusinessRule
  attr_accessor :priority, :prefix
  acts_as_hashish(:key => 'id', :indexes => {'l'=> 'lhs', 'r' => 'rhs', 'o' => 'op'})

  def initialize(json)
    hash = JSON.parse(json)
    @priority = hash['priority']
    @id = hash['id']
    push(hash)
  end

  # evaluate single rule
  def evaluate(params)
    
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

# {'id' => '1', 'lhs_id' => '2', 'op' => 'C', 'rhs_id' => '3', 'rule_id' => '1'}
# {'id' => '2', 'lhs' => '$product', 'op' => '==', 'rhs' => 'shoes', 'rule_id' => '1'}
# {'id' => '3', 'lhs' => '$discount', 'op' => '=', 'rhs' => '500', 'rule_id' => '1'}

# {'id' => '4', 'lhs_id' => '5', 'op' => 'C', 'rhs_id' => '6', 'rule_id' => '4'}
# {'id' => '5', 'lhs' => '$product', 'op' => '==', 'rhs' => 'clothes', 'rule_id' => '4'}
# {'id' => '6', 'lhs' => '$discount', 'op' => '=', 'rhs' => '200', 'rule_id' => '4'}

# example for discount on clothes and shoes

a = BusinessRule.new({
                       'priority' => nil,
                       'id' => '1',
                       'op' => 'C',
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
b = BusinessRule.new({
                       'priority' => nil,
                       'id' => '4',
                       'op' => 'C',
                       'lhs' => {
                         'id' => '5',
                         'lhs' => '$onwardAirline', 
                         'op' => 'IN', 
                         'rhs' => ['9W', 'IT']
                       }, 
                       'rhs' => {
                         'id' => '6',
                         'lhs' => '$discount', 
                         'op' => '=',
                         'rhs' => '200'
                       }}.to_json)
                       

# Bredis.evaluate([a, b], {'$product' => shoes})
