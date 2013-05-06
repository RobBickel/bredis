module Bredis
  class Operation
    OPERATORS = {
      # nothing by default
    }
    
    class << self

      def operate(op, lhs, rhs = nil)
        puts "\t#{lhs} #{op} #{rhs}"
        case op 
        when '=' # for consequence part currently supports only single (merge!)
          {lhs => rhs}
        when '&', '|', '+', '-', '*', '/', '==', '!='
          lhs.send(op, rhs)
        when '!'
          lhs.send(op)
        else
          OPERATORS[op].call(lhs, rhs)
        end
      end

      # allows you to add a new operator, a bit tricky!!!
      def operator(o)
        OPERATORS.merge!(o => Proc.new{|lhs, rhs| yield(lhs, rhs)})
      end

    end
    
  end
end
