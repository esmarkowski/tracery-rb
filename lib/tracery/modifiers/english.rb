require 'tracery/inflections/en'

# Automatically load inflections from the inflections directory 
# and use locale instead of module name. ex: :en
module Tracery
    module Modifiers
        module English
            A_REQUIRING_PATTERNS = /^(([bcdgjkpqtuvwyz]|onc?e|onearmed|onetime|ouija)$|e[uw]|uk|ubi|ubo|oaxaca|ufo|ur[aeiou]|use|ut([^t])|unani|uni(l[^l]|[a-ko-z]))/i
            AN_REQUIRING_PATTERNS = /^([aefhilmnorsx]$|hono|honest|hour|heir|[aeiou]|8|11)/i
            

            
            class << self
                def isVowel(c)
                    return ['a', 'e', 'i', 'o', 'u'].member?(c.downcase)
                end

                def replace(s, paramaters)
                    return s.gsub(/#{Regexp.quote(parameters[0])}/, parameters[1])
                end

                def titleize(s, paramaters)
                    s.titleize
                end
                alias capitalizeAll titleize

                def capitalize(s, paramaters)
                    s.capitalize
                end

                def indefinite_article(s, paramaters)
                    first_word = s.to_s.split(/[- ]/).first
                    if first_word[AN_REQUIRING_PATTERNS] && !first_word[A_REQUIRING_PATTERNS]
                    "an #{s}"
                    else
                    "a #{s}"
                    end unless first_word.nil?
                end
                alias a indefinite_article

                def upcase_first(s, parameters)
                    s.upcase_first
                end
                alias firstS upcase_first
                
                def pluralize(s, parameters)
                    s.pluralize
                end
                alias s pluralize

                def conjugate(s, parameters)
                    puts "Conjugate: #{s} #{parameters}"
                    s.verb.conjugate(**parameters.symbolize_keys.transform_values(&:to_sym))
                end
                alias ed conjugate
            end

        end
    end
end