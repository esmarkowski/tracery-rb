# frozen_string_literal: true
require "zeitwerk"
loader = Zeitwerk::Loader.for_gem
loader.setup # ready!

require 'json'
require 'verbs'

require 'active_support/all'
require_relative "tracery/version"


module Tracery
    # Parses a plaintext rule in the tracery syntax
    def createGrammar(raw)
        return Grammar.new(raw)
    end

    #handle random and replacement random
    @@internal_random = Random.new
    @@random_proc = lambda { @@internal_random.rand }
    def self.set_random(lambda_proc) 
        @@rnd_proc = lambda_proc
    end

    def self.reset_random
        set_random(lambda { @@internal_random.rand })
    end

    def self.random
        return @@random_proc.call 
    end

end







class TraceryTests
    include Tracery
    require 'pp'
    
    def test
        tests = {
            basic: ["", "a", "tracery"],
            hashtag: ["#a#", "a#b#", "aaa#b##cccc#dd#eee##f#"],
            hashtagWrong: ["##", "#", "a#a", "#aa#aa###"],
            escape: ["\\#test\\#", "\\[#test#\\]"],
        }
        
        tests.each do |key, testSet|
            puts "For #{key}:"
            testSet.each do |t|
                result = parse(t)
                puts "\tTesting \"#{t}\": #{result}"
            end
        end
        
        testGrammar = createGrammar({
            "animal" => ["capybara", "unicorn", "university", "umbrella", "u-boat", "boa", "ocelot", "zebu", "finch", "fox", "hare", "fly"],
            "color" => ["yellow", "maroon", "indigo", "ivory", "obsidian"],
            "mood" => ["elated", "irritable", "morose", "enthusiastic"],
            "story" => ["[mc:#animal#]Once there was #mc.a#, a very #mood# #mc#. In a pack of #color.ed# #mc.s#!"]
        });
        
        require "./mods-eng-basic"
        testGrammar.addModifiers(Modifiers.baseEngModifiers);
        puts testGrammar.flatten("#story#")
        
        grammar = createGrammar({"origin" => "foo"});
        grammar.addModifiers(Modifiers.baseEngModifiers);
        puts grammar.flatten("#origin#")
    end
end

if($PROGRAM_NAME == __FILE__) then
    tests = TraceryTests.new
    tests.test
end