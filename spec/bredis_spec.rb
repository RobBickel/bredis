describe Bredis::BusinessRule do
  describe "#initialize" do
    it "should initialize create rule in redis based on the rule hash"
  end

  describe "#evaluate" do
    it "should evaluate the rule and return the consequence based on the parameters passed"
  end
  
end

describe Bredis do
  describe ".import" do
    it "should create rule(s) in redis from the JSON file"
  end

  describe ".evaluate" do
    it "should evaluate the set of rules and return all the consequences"
  end

  describe ".search" do
    it "should search for rules based on options"
  end

end
