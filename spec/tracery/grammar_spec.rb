RSpec.describe Tracery::Grammar do


    context "Grammar" do

        let(:body_parts) { ['body', 'head', 'legs'] }
        let(:default_rules) { {body_part: body_parts} }
        let(:grammar) { Tracery::Grammar.new(default_rules) }


        context "Modifiers" do

            let(:grammar) { Tracery::Grammar.new(default_rules, Tracery::Modifiers::English) }
            
            context "backwards compatibility" do

                it '.s' do
                    expect(grammar.flatten("#body_part.s#")).to be_in(body_parts.map(&:pluralize))
                end

                it '.capitalize' do
                    expect(grammar.flatten("#body_part.capitalize#")).to be_in(body_parts.map(&:capitalize))
                end

                it '.capitalizeAll' do
                    expect(grammar.flatten("#body_part.capitalizeAll#")).to be_in(body_parts.map(&:titleize))
                end

                it '.firstS' do
                    expect(grammar.flatten("#body_part.firstS#")).to be_in(body_parts.map(&:upcase_first))
                end

            end

            it 'accepts modifiers' do
                grammar = Tracery::Grammar.new(default_rules, Tracery::Modifiers::English)
                result = grammar.flatten('#body_part.capitalize#')
                expect(result).to be_in(body_parts.map(&:capitalize))
            end
        end

        it 'keeps track of symbols' do
            expect(grammar.symbols[:body_part]).to eq body_parts
        end

        it 'creates new RuleSets' do
            grammar.push({injuries: ['missing #body_part#']}) 
            expect(grammar.symbols[:injuries]).to be_a Tracery::RuleSet
            expect(grammar.symbols[:injuries]).to include("missing #body_part#")
        end

        it 'returns a random rule' do
           expect(grammar.flatten("#body_part#")).to be_in(body_parts)
        end

        it 'expands a rule' do
            node = grammar.expand("#body_part#")
            expect(node).to be_a Tracery::Node
        end

        it 'appends to existing RuleSets' do
            grammar.push({body_part: ['arm']})
            expect(grammar.symbols[:body_part]).to eq (body_parts << 'arm')
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