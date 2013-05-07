module Bredis
  class RuleExpression

    def initialize(exp)
      @id = exp['id']
      push(exp)
    end
    
    # evaluate single rule
    def self.evaluate(exp, params)
      puts "EVAL : #{exp.inspect}"
      if !exp['lhs_id'].nil?
        lhs = evaluate(RuleSet.hashish_find(exp['lhs_id']), params)
      elsif params[exp['lhs']]
        lhs = params[exp['lhs']]
      else
        lhs = exp['lhs']
      end
      op = exp['op']
      if !exp['rhs_id'].nil?
        rhs = evaluate(RuleSet.hashish_find(exp['rhs_id']), params)
      elsif params[exp['rhs']]
        rhs = params[exp['rhs']]
      else
        rhs = exp['rhs']
      end
      Operation.operate(op, lhs, rhs)
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
      hash = {'id' => id, 'lhs' => lhs, 'op' => op, 'rhs' => rhs, 'lhs_id' => lhs_id, 'rhs_id' => rhs_id, 'rule_id' => @id}
      hash.merge!('category' => exp['category']) unless exp['category'].nil?
      hash.merge!('priority' => exp['priority']) unless exp['priority'].nil?
      RuleSet.hashish_insert(hash)
    end
    
  end
end
