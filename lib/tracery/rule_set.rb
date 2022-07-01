# Sets of rules
# (Can also contain conditional or fallback sets of rulesets)
module Tracery
    class RuleSet < Array
        attr_reader :grammar, :falloff, :default_uses
        attr_accessor :distribution
            

        def initialize(grammar, raw)
            @grammar = grammar
            @falloff = 1
            @errors = [] 
            @default_uses = {}
            
            case raw
                when Array then super(raw)
                when String then super([raw])
            end  # TODO: support for conditional and hierarchical rule sets

        end
        
        def select_rule
            # puts "Get rule #{@raw}"
            
            #TODO_ : RuleSet.getRule @ conditionalRule
            #TODO_ : RuleSet.getRule @ ranking
            
            unless self.blank?
                index = 0
                # Select from this basic array of rules
                # Get the distribution from the grammar if there is no other
                distribution = @distribution.to_s || grammar&.distribution 
                index = case(distribution)
                    when "shuffle"
                        #create a shuffled deck
                        #TODO_ - use fyshuffle and falloff
                        shuffled_deck = self.clone.shuffle if shuffled_deck.blank?
                        shuffled_deck.pop
                    when "weighted"
                        # weights = [5, 5, 10, 10, 20, 50]
                        # ps = weights.map { |w| (Float w) / weights.reduce(:+) } # normalize
                        # weighted_rules = @default_rules.zip(ps).to_h
                        # weighted_rules.max_by { |_, weight| rand ** (1.0 / weight) }.first
                        # wrs = -> (freq) { freq.max_by { |_, weight| rand ** (1.0 / weight) }.first }
                        raise "Weighted distribution not yet implemented"
                    when "falloff"
                        raise "Falloff distribution not yet implemented"
                    else
                        self[((Tracery.random ** falloff) * self.size).floor]
                end
            
                default_uses[index] = (default_uses[index] || 0) + 1
                return index
            end

            raise "No default rules defined for #{self}"
        end

        def clear
            default_uses = {}
        end

    end
end