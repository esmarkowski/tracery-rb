module Tracery
    class Node
        attr_accessor :grammar, :depth, :finished_text, :children, :errors
        
        include Tracery #  TODO: WHY?

        def initialize(parent, child_index, settings)
            @errors = []
            @children = []

            if settings[:raw].nil?
                @errors << "Empty input for node"
                settings[:raw] = ""
            end
            
            # If the root node of an expansion, it will have the grammar passed as the 'parent'
            # set the grammar from the 'parent', and set all other values for a root node
            if(parent.is_a? Grammar)
                @grammar = parent
                @parent = nil
                @depth = 0
                # @child_index = 0
            else
                @grammar = parent.grammar
                @parent = parent
                @depth = parent.depth + 1
                # @child_index = childIndex # TODO: Does nothing
            end

            @raw = settings[:raw]
            @type = settings[:type]
            @is_expanded = false
            
            @errors << "No grammar specified for this node #{self}" if (@grammar.nil?)
        end

        def expanded?
            @is_expanded
        end
        
        def to_s
            "Node('#{@raw}' #{@type} d:#{@depth})"
        end

        def expand_children(child_rule, prevent_recursion)
            @finished_text = ""
            @child_rule = child_rule
            
            if(!@child_rule.nil?)
                parsed = parse(child_rule)
                sections = parsed[:sections]

                @errors.concat(parsed[:errors])

                sections.each_with_index do |section, i|
                    child = Tracery::Node.new(self, i, section)
                    if(!prevent_recursion)
                        child.expand(prevent_recursion)
                    end
                    @finished_text += child.finished_text
                    @children << child
                end
            else
                # In normal operation, this shouldn't ever happen
                @errors << "No child rule provided, can't expand children"
            end
        end
        
        # Expand this rule (possibly creating children)
        def expand(prevent_recursion = false)
            if expanded? 
                @errors << "Already expanded #{self}"
                return
            end

            @is_expanded = true
            #this is no longer used
            @expansion_errors = []
                    
            # Types of nodes
            # -1: raw, needs parsing
            #  0: Plaintext
            #  1: Tag ("#symbol.mod.mod2.mod3#" or "#[pushTarget:pushRule]symbol.mod#")
            #  2: Action ("[pushTarget:pushRule], [pushTarget:POP], [pushTarget:REPLACE]", more in the future)
            
            case(@type)
                when -1 then
                    #raw rule
                    expand_children(@raw, prevent_recursion)
                when 0 then
                    #plaintext, do nothing but copy text into finished text
                    @finished_text = @raw
                when 1 then
                    #tag - Parse to find any actions, and figure out what the symbol is
                    @pre_actions = []
                    @post_actions = []
                    parsed = parse_tag(@raw)
                    @symbol = parsed[:symbol]
                    @modifiers = parsed[:modifiers]

                    # Create all the pre_actions from the raw syntax
                    @pre_actions = parsed[:pre_actions].map{|pre_action|
                        Tracery::NodeAction.new(self, pre_action[:raw])
                    }

                    # @post_actions = parsed[:pre_actions].map{|post_actions|
                    #     Tracery::NodeAction.new(self, post_actions.raw)
                    # }
                    
                    # Make undo actions for all pre_actions (pops for each push)
                    @post_actions = @pre_actions.
                                    select{|pre_action| pre_action.type == 0 }.
                                    map{|pre_action| pre_action.create_undo() }
                    
                    @pre_actions.each { |pre_action| pre_action.activate }
                    
                    @finished_text = @raw

                    # Expand (passing the node, this allows tracking of recursion depth)
                    selected_rule = @grammar.select_rule(@symbol, self, @errors)

                    expand_children(selected_rule, prevent_recursion)
                    
                    # Apply modifiers
                    # TODO: Update parse function to not trigger on hashtags within parenthesis within tags,
                    # so that modifier parameters can contain tags "#story.replace(#protagonist#, #newCharacter#)#"
                    @modifiers.each{|mod_name|
                        mod_params = [];
                        if mod_name.include?("(")
                            #match something like `modifier(param, param)`, capture name and params separately
                            match = /([^\(]+)\(([^)]+)\)/.match(mod_name)
                            unless match.nil?
                                mod_params = if match.captures[1] =~ /:/
                                    Hash[match.captures[1].scan(/([\w\d]+):\s?([\w\d]+)/)]
                                else
                                    match.captures[1]
                                end
                                mod_name = match.captures[0]
                            end
                        end

                        # reverse the order so only latest matching modifier is applied
                        mod = @grammar.modifiers.reverse.find {|mod| mod.respond_to? mod_name }
                        
                        # Missing modifier?
                        if mod.blank?
                            @errors << "Missing modifier #{mod_name}"
                            @finished_text += "((.#{mod_name}))"
                        else
                            @finished_text = mod.send(mod_name.to_sym, @finished_text, mod_params)
                        end
                    }
                    # perform post-actions
                    @post_actions.each{|post_action| post_action.activate()}
                when 2 then
                    # Just a bare action? Expand it!
                    @action = Tracery::NodeAction.new(self, @raw)
                    @action.activate()
                    
                    # No visible text for an action
                    # TODO: some visible text for if there is a failure to perform the action?
                    @finished_text = ""
                when 3 then
                    
                    pre_expansion = expand_children(@raw, prevent_recursion)
                    composite_rule = "##{@finished_text}#"

                    @raw = composite_rule
                    expand_children(@raw, prevent_recursion)

            end
            self
        end

        def parse(rule)
            depth = 0
            in_tag = false
            results = {errors: [], sections: []}
            escaped = false
            
            errors = []
            start = 0
            
            escaped_substring = ""
            last_escaped_char = nil
    
            if rule.nil?
                sections = {errors: errors, sections: []}
                return sections
            end
            
            rule.each_char.with_index do |c, i|
                unless escaped
                    case(c)
                        when '[' then
                            # Enter a deeper bracketed section
                            if(depth == 0 && !in_tag) then
                                if(start < i) then
                                    create_section(start, i, 0, results, last_escaped_char, escaped_substring, rule, errors)
                                    last_escaped_char = nil
                                    escaped_substring = ""
                                end
                                start = i + 1
                            end
                            depth += 1
                        when ']' then
                            depth -= 1
                            # End a bracketed section
                            if(depth == 0 && !in_tag) then
                                create_section(start, i, 2, results, last_escaped_char, escaped_substring, rule, errors)
                                last_escaped_char = nil
                                escaped_substring = ""
                                start = i + 1
                            end
                        when '#' then
                            # Hashtag
                            #   ignore if not at depth 0, that means we are in a bracket
                            if(depth == 0) then
                                if(in_tag) then
                                    create_section(start, i, 1, results, last_escaped_char, escaped_substring, rule, errors)
                                    last_escaped_char = nil
                                    escaped_substring = ""
                                    start = i + 1
                                else
                                    if(start < i) then
                                        create_section(start, i, 0, results, last_escaped_char, escaped_substring, rule, errors)
                                        last_escaped_char = nil
                                        escaped_substring = ""
                                    end
                                    start = i + 1
                                end
                                in_tag = !in_tag
                            end
                        when '<' then
                                if(start < i) then
                                    create_section(start, i, 0, results, last_escaped_char, escaped_substring, rule, errors)
                                    last_escaped_char = nil
                                    escaped_substring = ""
                                end
                                start = i + 1
                            depth += 1
                        when '>' then
                            # End a bracketed section
                            # if(!in_tag) then
                                create_section(start, i, 3, results, last_escaped_char, escaped_substring, rule, errors)
                                last_escaped_char = nil
                                escaped_substring = ""
                                start = i + 1
                            # end
                            depth -= 1
                        when '\\' then
                            escaped = true;
                            escaped_substring = escaped_substring + rule[start...i];
                            start = i + 1;
                            last_escaped_char = i;
                    end
                else
                    escaped = false
                end
            end #each character in rule
            
            if(start < rule.length) then
                create_section(start, rule.length, 0, results, last_escaped_char, escaped_substring, rule, errors)
                last_escaped_char = nil
                escaped_substring = ""
            end
            
            errors << ("Unclosed tag") if in_tag
            errors << ("Too many [") if depth > 0
            errors << ("Too many ]") if depth < 0
    
            # Strip out empty plaintext sections
            results[:sections].select! {|section| 
                if(section[:type] == 0 && section[:raw].empty?) then
                    false
                else
                    true
                end
            }
            results[:errors] = errors;
            return results
        end

        #TODO_: needs heavy refactoring -- no nesting in ruby (ie. move entire parser to another class w/ shared state)
        def create_section(start, finish, type, results, last_escaped_char, escaped_substring, rule, errors)
            if(finish - start < 1) then
                if(type == 1) then
                    errors << "#{start}: empty tag"
                else
                    if(type == 2) then
                        errors << "#{start}: empty action"
                    end
                end
            end
            rawSubstring = ""
            if(!last_escaped_char.nil?) then
                rawSubstring = escaped_substring + "\\" + rule[(last_escaped_char+1)...finish]
            else
                rawSubstring = rule[start...finish]
            end
            
            results[:sections] << {
                    type: type,
                    raw: rawSubstring
                }
        end

        def parse_tag(tag_contents)
            parsed = {
                    symbol: nil,
                    pre_actions: [],
                    post_actions: [],
                    modifiers: []
                }
            
            sections = parse(tag_contents)[:sections]
            symbol_section = nil;
            sections.each do |section|
                if(section[:type] == 0)
                    if(symbol_section.nil?) 
                        symbol_section = section[:raw]
                    else
                        raise "multiple main sections in #{tag_contents}"
                    end
                else
                    parsed[:pre_actions].push(section)
                end
            end
            
            if(symbol_section.nil?)
                # raise "no main section in #{tag_contents}"
            else
                
                # split on single \. only
                components = symbol_section.split(/(?<!\.)\.(?!\.)/);
                parsed[:symbol] = components.first
                parsed[:modifiers] = components.drop(1)
            end
    
            return parsed
        end

        def all_errors
            child_errors = @children.inject([]){|all, child| all.concat(child.all_errors)}
            return child_errors.concat(@errors) 
        end

        def clear_escape_characters
            @finished_text = @finished_text.gsub(/\\\\/, "DOUBLEBACKSLASH").gsub(/\\/, "").gsub(/DOUBLEBACKSLASH/, "\\")
        end
    end


end