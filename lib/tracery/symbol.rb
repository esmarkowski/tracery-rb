module Tracery
    class Symbol
        attr_accessor :is_dynamic
        
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
        
        def push(rules)
            @stack.push RuleSet.new(@grammar, rules)
        end
        
        def pop
            @stack.pop
        end
        
        def select_rule(node, errors)
            @uses.push({ node: node })
            if(@stack.empty?) then
                errors << "The rule stack for '#{@key}' is empty, too many pops?"
                return "((#{@key}))"
            end
            return @stack.last.select_rule
        end

        def get_active_rules
            return nil if @stack.empty?
            return @stack.last.select_rule 
        end

        def inspect
            return "Symbol(#{@base_rules.inspect})"
        end

        def to_json
            @rules.to_json
        end
    end

end