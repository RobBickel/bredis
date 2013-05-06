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

# some operators

Bredis::Operation.operator('IN') do |lhs, rhs|
  rhs.member?(lhs)
end

Bredis::Operation.operator('NOT IN') do |lhs, rhs|
  !rhs.member?(lhs)
end

Bredis::Operation.operator('=~') do |lhs, rhs|
  lhs =~ /#{rhs}/
end
