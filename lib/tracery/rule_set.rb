# Sets of rules
# (Can also contain conditional or fallback sets of rulesets)
module Tracery
    class RuleSet
        attr_reader :grammar, :falloff, :default_uses, :default_rules

        def initialize(grammar, raw)
            @grammar = grammar
            @falloff = 1
            
            @default_uses = {}
            
            @default_rules = case raw
                when Array then raw
                when String then [raw]
            end  # TODO: support for conditional and hierarchical rule sets

        end
        
        def select_rule
            # puts "Get rule #{@raw}"
            
            #TODO_ : RuleSet.getRule @ conditionalRule
            #TODO_ : RuleSet.getRule @ ranking
            
            if default_rules.present?
                index = 0
                # Select from this basic array of rules
                # Get the distribution from the grammar if there is no other
                distribution = @distribution || grammar.distribution
                case(distribution)
                    when "shuffle" then
                        #create a shuffled deck
                        if(@shuffled_deck.nil? || @shuffled_deck.empty?)
                            #TODO_ - use fyshuffle and falloff
                            @shuffled_deck = (0...@default_rules.size).to_a.shuffle
                        end
                        index = @shuffled_deck.pop
                    when "weighted" then
                        @errors << "Weighted distribution not yet implemented"
                    when "falloff" then
                        @errors << "Falloff distribution not yet implemented"
                    else
                        index = ((Tracery.random ** falloff) * default_rules.size).floor
                end
            
                default_uses[index] = (default_uses[index] || 0) + 1
                return default_rules[index]
            end

            @errors << "No default rules defined for #{self}"
            return nil
        end
        
        def clear
            default_uses = {}
            #TODO_ should clear shuffled deck too?
        end


        def inspect
            return "RuleSet(#{@default_rules.inspect})"
        end
    end
end