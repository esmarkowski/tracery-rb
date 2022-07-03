RSpec.describe Tracery::Node do

            # Types of nodes
            # -1: raw, needs parsing
            #  0: Plaintext
            #  1: Tag ("#symbol.mod.mod2.mod3#" or "#[pushTarget:pushRule]symbol.mod#")
            #  2: Action ("[pushTarget:pushRule], [pushTarget:POP], [pushTarget:REPLACE]", more in the future)

    let(:grammar) { Tracery::Grammar.new({}, [Tracery::Modifiers::English]) }

    it 'expand returns self' do
            grammar.push({"some_tag": ["Hello World"]})
            node = Tracery::Node.new(grammar, 0, {
                type: -1,
                raw: "#some_tag.s#"
            })

            expanded = node.expand
            expect(expanded).to eq node
            expect(expanded.finished_text).to eq("Hello Worlds")
    end

    context "plain text" do


        it 'should be able to create a plain text node' do
        
            node = Tracery::Node.new(grammar, 0, {
                type: 0,
                raw: "Hello World"
            })
            node.expand
            expect(node.finished_text).to eq("Hello World")
        end
        
    end

    context "rules" do
        
        it 'expands a rule' do
            grammar.push({"some_tag": ["Hello World"]})
            node = Tracery::Node.new(grammar, 0, {
                type: -1,
                raw: "#some_tag#"
            })

            node.expand
            expect(node.finished_text).to eq("Hello World")
        end

        it 'expands a rule with a modifier' do
            grammar.push({"some_tag": ["Hello World"]})
            node = Tracery::Node.new(grammar, 0, {
                type: -1,
                raw: "#some_tag.s#"
            })

            expect(node.expand.finished_text).to eq("Hello Worlds")
            expect(node.finished_text).to eq("Hello Worlds")
        end

        it 'expands a tag' do
            grammar.push({"some_tag": ["Hello World"]})
            node = Tracery::Node.new(grammar, 0, {
                type: -1,
                raw: "[new_tag:#some_tag#]#new_tag#"
            })
            node.expand
            expect(node.finished_text).to eq("Hello World")
        end

        it 'handles composite rules' do
            grammar.push({"gender": ["female"], "female_name": ['lilly']})
            node = Tracery::Node.new(grammar, 0, {
                type: -1,
                raw: "<#gender#_name>"
            })
            node.expand
            expect(node.finished_text).to eq("lilly")
        end
        
        it 'handles composite rules in tags' do
            grammar.push({"gender": ["female"], "female_name": ['lilly']})
            node = Tracery::Node.new(grammar, 0, {
                type: -1,
                raw: "[name:<#gender#_name>]#name#"
            })
            node.expand
            puts node.errors
            expect(node.finished_text).to eq("lilly")
        end
    end

    context "actions" do
        
    end

end