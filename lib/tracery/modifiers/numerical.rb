module Tracery
    module Modifiers
        module Numerical


            class << self

                def random(s,parameters)
                    if parameters =~ /\.{2,3}/
                        range = Range.new(*parameters.split(/\.{2,3}/).map(&:to_i))
                        rand(range).to_s
                    else
                        rand(parameters.to_i).to_s
                    end
                end


            end

        end
    end
end
