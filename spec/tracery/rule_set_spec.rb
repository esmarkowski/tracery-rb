RSpec.describe Tracery::RuleSet do

    context "RuleSet" do
        it 'behaves like an Array' do
            rule_set = Tracery::RuleSet.new(nil, ['test', 'a'])
        end

        it 'responds to include?' do
            rule_set = Tracery::RuleSet.new(nil, ['test', 'a'])
            expect(rule_set.include?('a')).to be true
            expect(rule_set.include?('b')).to be false
        end

        it 'selects a rule' do
            rule_set = Tracery::RuleSet.new(nil, ['test', 'a'])
            expect(rule_set.select_rule).to be_in(['test', 'a'])
        end

        it 'tracks rule usage' do
            rule_set = Tracery::RuleSet.new(nil, ['test', 'a', 'b'])
            track = rand(5...10).times.map { rule_set.select_rule }.tally
            expect(rule_set.default_uses).to eq track
        end

        it 'shuffles' do
            rules = ['test', 'a', 'b']
            rule_set = Tracery::RuleSet.new(nil, rules)
            rule_set.distribution = 'shuffle'
            expect(rule_set.select_rule).to be_in(rules)
        end

        it 'does weighted selection' do
            skip("Weighted distribution not yet implemented")
            rules = ['test', 'a', 'b']
            rule_set = Tracery::RuleSet.new(nil, rules)
            rule_set.distribution = 'weighted'
            expect(rule_set.select_rule).to be_in(rules)
        end

        it 'does falloff selection' do
            skip("Falloff distribution not yet implemented")
            rules = ['test', 'a', 'b']
            rule_set = Tracery::RuleSet.new(nil, rules)
            rule_set.distribution = 'falloff'
            expect(rule_set.select_rule).to be_in(rules)
        end
    end

end