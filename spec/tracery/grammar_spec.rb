RSpec.describe Tracery::Grammar do


    context "Grammar" do

        let(:grammar) { Tracery::Grammar.new({body_part: ['body', 'head', 'legs']}) }

        context "Modifiers" do
            it 'accepts modifiers' do
                grammar = Tracery::Grammar.new({body_part: ['body', 'head', 'legs']}, Tracery::Modifiers::English)
                result = grammar.flatten('#body_part.capitalize#')
                expect(result).to be_in(['body', 'head', 'legs'].map(&:capitalize))
            end
        end

        it 'keeps track of symbols' do
            expect(grammar.symbols[:body_part]).to eq ['body', 'head', 'legs']
        end

        it 'creates new RuleSets' do
            grammar.push({injuries: ['missing #body_part#']}) 
            expect(grammar.symbols[:injuries]).to be_a Tracery::RuleSet
            expect(grammar.symbols[:injuries]).to include("missing #body_part#")
        end

        it 'returns a random rule' do
           expect(grammar.flatten("#body_part#")).to be_in(['body', 'head', 'legs'])
        end

        it 'expands a rule' do
            node = grammar.expand("#body_part#")
            expect(node).to be_a Tracery::Node
        end

        it 'appends to existing RuleSets' do
            grammar.push({body_part: ['arm']})
            expect(grammar.symbols[:body_part]).to eq ['body', 'head', 'legs', 'arm']
        end

        it 'expands nested rules' do
            head_parts =  ['eye', 'mouth', 'nose']
            grammar.push({
                head_parts: head_parts,
                injuries: ['[head_injury:#head_parts#]']
            })
            expect(grammar.flatten("#injuries##head_injury#")).to be_in(head_parts) 
        end

    end

end