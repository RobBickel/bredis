module Bredis

  # search '$product' => 'shoes', '$price' => (0..500).to_a
  def self.search(query_hash, options = {})
    filters = {}
    query_hash.each do |key, value|
      filters.merge!('l' => key, 'r' => value)
    end
    options.merge(:filters => filters)
    BusinessRule.hashish_list(options)
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
      if ((rule['lhs_id'] and BusinessRule.evaluate(BusinessRule.hashish_find(rule['lhs_id']), params)) or rule['lhs'])
        matches += 1
        result << ((rule['rhs_id'] and BusinessRule.evaluate(BusinessRule.hashish_find(rule['rhs_id']), params)) or rule['rhs'])
      end
    end
    return result
  end
end

