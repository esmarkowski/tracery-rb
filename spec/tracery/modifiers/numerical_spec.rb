RSpec.describe Tracery::Modifiers::Numerical do

    it 'random ranges' do
        age = Tracery::Grammar.new({"age": ["#n.random(0..30)#"]}, [Tracery::Modifiers::Numerical]).flatten("#age#")
        expect(age.to_i).to be_between(0, 30)
    end

    it 'random number' do
        age = Tracery::Grammar.new({"age": ["#n.random(2)#"]}, [Tracery::Modifiers::Numerical]).flatten("#age#")
        expect(age.to_i).to be_between(0, 2)
    end

    it 'adds' do
        age = Tracery::Grammar.new({"base_age": ["20"],"age": ["#base_age.add(20)#"]}, [Tracery::Modifiers::Numerical]).flatten("#age#")
        expect(age.to_i).to eq 40
    end

    it 'subtracts' do
        age = Tracery::Grammar.new({"base_age": ["20"],"age": ["#base_age.subtract(5)#"]}, [Tracery::Modifiers::Numerical]).flatten("#age#")
        expect(age.to_i).to eq 15
    end

    it 'multiplies' do
        age = Tracery::Grammar.new({"base_age": ["20"],"age": ["#base_age.multiply(5)#"]}, [Tracery::Modifiers::Numerical]).flatten("#age#")
        expect(age.to_i).to eq 100
    end

    it 'subtracts' do
        age = Tracery::Grammar.new({"base_age": ["20"],"age": ["#base_age.divide(5)#"]}, [Tracery::Modifiers::Numerical]).flatten("#age#")
        expect(age.to_i).to eq 4
    end
end