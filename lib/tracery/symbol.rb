module Tracery
    class Symbol < Array
        attr_accessor :is_dynamic
        delegate :concat, :push, :include?, to: :rules

        def initialize(grammar, key, raw_rules)
            # Symbols can be made with a single value, and array, or array of objects of (conditions/values)
            @key = key
            @grammar = grammar
            
            @base_rules = RuleSet.new(@grammar, raw_rules)
            clear
        end
        
        def clear
            # Clear the stack and clear all ruleset usages
            @stack = [@base_rules]
            @uses = []
            @base_rules.clear
        end

        def rules
            @stack
        end

        
        def pop
            @stack.pop
        end
        
        def select_rule(node = nil, errors = [])
            @uses.push({ node: node }) if node.present?
            if(@stack.empty?)
                errors << "The rule stack for '#{@key}' is empty, too many pops?"
                return "((#{@key}))"
            end
            return @stack.last.select_rule
        end


        def to_json
            @rules.to_json
        end
    end

end