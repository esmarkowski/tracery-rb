module Tracery
    class Grammar
        attr_accessor :distribution, :modifiers, :symbols, :subgrammars

        def initialize(raw, modifiers = [])
            @modifiers = [modifiers].flatten
            load(raw)
        end

        def self.from_json(path_to_file, modifiers = [])
            json = JSON.parse(File.read(path_to_file))
            return Grammar.new(json, modifiers)
        end
        
        def clear_state
            @symbols.each{|k,v| v.clear_state} # TODO_ check for nil keys
        end
        
        def load(raw)
            @symbols = {}
            @subgrammars = []
            return if(raw.nil?)
            @symbols = raw.inject({}) { |memo, (key, value)| memo[key] = Tracery::RuleSet.new(self, value); memo }.with_indifferent_access
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
        
        def push_rules(key, raw_rules, source_action = nil)
            # Create or push rules
            unless(@symbols.has_key? key.to_sym)
                @symbols[key.to_sym] = Tracery::RuleSet.new(self, raw_rules)
                # @symbols[key.to_sym].is_dynamic = true if source_action
            else
                @symbols[key.to_sym].concat(raw_rules)
            end
        end

        def push(rules = {})
            rules.each { |key, value| push_rules(key, value) }
        end
        
        def pop_rules(key)
            errors << "No symbol for key #{key}" if(@symbols[key].nil?)
            @symbols[key].pop
        end
        
        def select_rule(key, node = nil, errors = [])
            return @symbols[key].select_rule if symbols.has_key? key
                
            
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

        def respond_to?(method_name, include_private = false)
            symbols.has_key?(method_name.to_sym) || self.instance_variables.include?("@#{method_name}".to_sym) || super
        end
        private

        def method_missing(m, *args, &block)
            if symbols.has_key?(m.to_sym)
                symbols[m.to_sym]
            #   self.send(@@[m.to_sym], *args, &block)
            else
              raise ArgumentError.new("Method `#{m}` doesn't exist.")
            end
        end
        



        def create_root(rule)
            # Create a node and subnodes
            root = Tracery::Node.new(self, 0, {
                        type: -1,
                        raw: rule
                    })
        end
    end
end