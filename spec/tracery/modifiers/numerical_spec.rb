RSpec.describe Tracery::Modifiers::Numerical do

    it 'random ranges' do
        age = Tracery::Grammar.new({"age": ["#n.random(0..30)#"]}, [Tracery::Modifiers::Numerical]).flatten("#age#")
        expect(age.to_i).to be_between(0, 30)
    end

    it 'random number' do
        age = Tracery::Grammar.new({"age": ["#n.random(2)#"]}, [Tracery::Modifiers::Numerical]).flatten("#age#")
        expect(age.to_i).to be_between(0, 2)
    end

end