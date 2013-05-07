module Bredis
  class RuleSet
    
    def initialize(category, redis)
      @redis_connection = redis
      Hashish.configure {|c| c.redis_connection = redis}
      RuleSet.acts_as_hashish(:key => 'id', :indexes => {'l'=> 'lhs', 'r' => 'rhs', 'o' => 'op'})
    end
    
    # search '$product' => 'shoes', '$price' => (0..500).to_a
    def search(query_hash, options = {})
      filters = {}
      query_hash.each do |key, value|
        filters.merge!('l' => key, 'r' => value)
      end
      options.merge(:filters => filters)
      RuleSet.hashish_list(options)
    end
    
    # imports many rules into the engine from a one or many JSON rules or JSON file
    def self.import(json)
      
    end
    
    def evaluate(params = {}, max_match = 1)
      result = []
      matches = 0
      RuleSet.hashish_list(:filters => {'o' => '?'}, :page_size => 0).each do |rule|
        break if matches >= max_match
        # trickly because of logical operators in the rule
        if ((rule['lhs_id'] and RuleExpression.evaluate(RuleSet.hashish_find(rule['lhs_id']), params)) or rule['lhs'])
          matches += 1
          result << ((rule['rhs_id'] and RuleExpression.evaluate(RuleSet.hashish_find(rule['rhs_id']), params)) or rule['rhs'])
        end
      end
      return result
    end
  end
end

