# Types of actions:
# 0 Push: [key:rule]
# 1 Pop: [key:POP]
# 2 function: [functionName(param0,param1)] (TODO!)
module Tracery
    class NodeAction
        attr_accessor :node, :target, :type, :ruleNode
        def initialize(node, raw)
            # puts("No node for NodeAction") if(node.nil?)
            # puts("No raw commands for NodeAction") if(raw.empty?)
            
            @node = node
            
            sections = raw.split(":")
            @target = sections.first
            if(sections.size == 1) then
                # No colon? A function!
                @type = 2
            else
                # Colon? It's either a push or a pop or a replace
                @rule = sections[1] || ""
                @type = case(@rule)
                    when /^POP/ then 1
                    when /^SET/ then 3
                    else 0
                end
            end
        end
        
        def activate
            grammar = @node.grammar
            case(@type)
                when 0 then
                    # split into sections (the way to denote an array of rules)
                    rule_sections = @rule.split(",")
                    finished_rules = rule_sections.map do |rule_section|
                        n = Tracery::Node.new(grammar, 0, {
                                type: -1,
                                raw: rule_section
                            })
                        n.expand
                        n.finished_text
                    end
                    
                    # TODO: escape commas properly
                    grammar.push_rules(@target, finished_rules, self)
                    # puts("Push rules: #{@target} #{@ruleText}")
                when 1 then
                    grammar.pop_rules(@target);
                when 2 then
                    grammar.flatten(@target, true);
                when 3 then
                    match = @rule.match(/SET(?<rule>.*)$/)
                    replacment_value = grammar.flatten(match.named_captures["rule"])
                    grammar.replace(@target, replacment_value);

            end
        end

        def create_undo
            if(@type == 0) then
                return Tracery::NodeAction.new(@node, "#{@target}:POP")
            end
            # TODO Not sure how to make Undo actions for functions or POPs
            return nil
        end

        def toText
            case(@type)
                when 0 then "#{@target}:#{@rule}"
                when 1 then "#{@target}:POP"
                when 2 then "((some function))"
                when 3 then "#{@target}:SET:#{@rule}"
                else "((Unknown Action))"
            end
        end
    end

end