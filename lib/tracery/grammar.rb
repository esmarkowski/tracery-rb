module Tracery
    class Grammar
        attr_accessor :distribution, :modifiers, :symbols, :subgrammars

        def initialize(raw) #, settings
            @modifiers = []
            load(raw)
        end

        def self.from_json(path_to_file)
            json = JSON.parse(File.read(path_to_file))
            return Grammar.new(json)
        end
        
        def clear_state
            @symbols.each{|k,v| v.clear_state} # TODO_ check for nil keys
        end
        
        # TODO: Allow modifiers << mods
        # TODO: change to add_modifiers
        def add_modifiers(mods)
            # copy over the base modifiers
            modifiers.push(mods)
            # mods.each{|k,v| @modifiers[k] = v}
        end
        
        # TODO: rename to load 
        def load(raw)
            @symbols = {}
            @subgrammars = []
            return if(raw.nil?)
            @symbols = raw.inject({}) { |memo, (key, value)| memo[key] = Tracery::Symbol.new(self, key, value); memo }
        end

        
        def expand(rule, allow_escape_chars = false)
            root = create_root(rule)
            root.expand
            root.clear_escape_characters unless allow_escape_chars
            return root
        end
        
        def flatten(rule, allow_escape_chars = false)
            return expand(rule, allow_escape_chars).finished_text
        end
        
        def push_rules(key, raw_rules, source_action)
            # Create or push rules
            if(@symbols[key].nil?) then
                @symbols[key] = Tracery::Symbol.new(self, key, raw_rules)
                @symbols[key].is_dynamic = true if source_action
            else
                @symbols[key].push(raw_rules)
            end
        end
        
        def pop_rules(key)
            errors << "No symbol for key #{key}" if(@symbols[key].nil?)
            @symbols[key].pop
        end
        
        def select_rule(key, node, errors)
            if(@symbols.has_key? key) 
                return @symbols[key].select_rule(node, errors)
            end
            
            # Failover to alternative subgrammars
            @subgrammars.each do |subgrammar|
                if(subgrammar.symbols.has_key? key) then
                    return subgrammar.symbols[key].select_rule
                end
            end
            
            # No symbol?
            errors << "No symbol for '#{key}'"
            return "((#{key}))"
        end



        def to_json
            # symbols = @symbols.each.collect(&:as_json)
            @symbols.to_json
            # {|symkey, symval| "\"#{symkey}\": #{symval.to_json}"}
            # return "{\n#{symbols.join("\n")}\n}"
        end

        def to_s
        end

        def inspect
            return "Tracery::Grammar(#{@symbols.size} symbols) @symbols=#{@symbols.inspect}"
        end

        private
        def create_root(rule)
            # Create a node and subnodes
            root = Tracery::Node.new(self, 0, {
                        type: -1,
                        raw: rule
                    })
        end
    end
end