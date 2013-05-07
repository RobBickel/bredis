require 'benchmark'
def benchmark(n)
  # create some rules
  test_rules = Bredis::RuleSet.new('test', Redis.new(:db => 3))
  $redis_connection = test_rules.instance_variable_get(:@redis_connection)
  $redis_connection.flushdb
  mb1 = $redis_connection.info['used_memory_human']
  n.times do 
    test_rules << {'id' => next_seq, 'op' => '?', 'lhs' => random_expression, 'rhs' => {'id' => next_seq, 'lhs' => '$result', 'rhs' => random_expression, 'op' => '='}}
  end
  result = nil
  t = Benchmark.realtime do
    result = test_rules.evaluate({}, n)
  end
  mb2 = $redis_connection.info['used_memory_human']
  puts "Evaluated #{test_rules.length} expressions among #{test_rules.length} rules in #{t} seconds"
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
  $redis_connection.incr('SEQ').to_i
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
