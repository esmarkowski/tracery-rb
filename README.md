# Tracery::Rb


## About
Tracery was developed by Kate Compton

## Installation

Install the gem and add to the application's Gemfile by executing:

    $ bundle add tracery-rb

If bundler is not being used to manage dependencies, install the gem by executing:

    $ gem install tracery-rb

## Usage

### Create a grammar

Using the ruby port is very similar to the Javascript version. First, install the tracery gem: `gem install tracery`.

Create an empty grammar:

```ruby
require 'tracery'
grammar = Tracery::Grammar.new({origin: "goats"});
```

Create a grammar from a Tracery-formatted object:

```ruby
grammar = Tracery::Grammar.new({origin: "goats"});
```

Load a grammar from JSON:

```ruby
grammar = Tracery::Grammar.from_json('test/flower_names.json')
```

Add modifiers to the grammar (`tracery/modifiers/english.rb` for basic English modifiers, or write your own)

```ruby
grammar.modifiers << Tracery::Modifiers::English
```

### Expand rules 
Get the fully-expanded string from a rule

```ruby
expanded_text = grammar.flatten("#origin#")
```

Get the fully-expanded node from a rule, this will return a root node containing a full expanded tree with many potentially interesting properties, including "finishedText" for each node.

```ruby
expanded_node = grammar.expand("#origin#")
```

### Making Tracery deterministic

By default, Tracery uses `Random#rand` to generate random numbers. If you need Tracery to be deterministic, you can make it use your own random number generator using:

```ruby
Tracery.set_random(rng_lambda)
```

where `rng_lambda` is a lambda that, [like Random#rand](http://ruby-doc.org/core-2.0.0/Random.html#method-i-rand), returns a floating-point, pseudo-random number in the range `[0, 1)`. By using a local random number generator that takes a seed and controlling this seed, you can make Tracery's behavior completely deterministic.

Usage example:
```ruby
Tracery.set_random(lambda { return 0.5 })
```

Note: Beware, this lambda is set *globally*, for all Tracery expansions.

## Library Concepts
### Grammar

A Grammar is

* *a dictionary of symbols*: a key-value object matching keys (the names of symbols) to expansion rules
* optional metadata such as a title, edit data, and author
* optional connectivity graphs describing how symbols call each other

*clearState*: symbols and rulesets have state (the stack, and possible ruleset state recording recently called rules).  This function clears any state, returning the dictionary to its original state;

Grammars are usually created by feeding in a raw JSON grammar, which is then parsed into symbols and rules.  You can also build your own Grammar objects from scratch, without using this utility function, and can always edit the grammar after creating it.

### Symbol
A symbol is a **key** (usually a short human-readable string) and a set of expansion rules
* the key
* rulesetStack: the stack of expansion **rulesets** for this symbol.  This stack records the previous, inactive rulesets, and the current one.
* optional connectivity data, such as average depth and average expansion length

Putting a **key** in hashtags, in a Tracery syntax object, will create a expansion node for that symbol within the text.

Each top-level key-value pair in the raw JSON object creates a **symbol**.  The symbol's *key* is set from the key, and the *value* determines the **ruleset**.

### Modifier
A function that takes a string (and optionally parameters) and returns a string.  A set of these is included in `tracery/modifiers/english.rb`.  Modifiers are applied, in order, after a tag is fully expanded.

To apply a modifier, add its name after a period, after the tag's main symbol:

	#animal.capitalize#
	#booktitle.titleize#
	Hundreds of #animal.pluralize#
	Hundreds of #animal.s#
    Matt #verb.ed(tense: past)#

    #animal.a#
    #animal.indefinite_article#

Modifiers can have parameters, too!
	#story.replace(he,she).replace(him,her).replace(his,hers)#

### Action
An action that occurs when its node is expanded.  Built-in actions are 
* Generating some rules "[key:#rule#]" and pushing them to the "key" symbol's rule stack.  If that symbol does not exist, it creates it.
* Popping rules off of a rule stack, "[key:POP]"
* Other functions

TODO: figure out syntax and implementation for generating *arrays* of rules, or other complex rulesets to push onto symbols' rulestacks

TODO: figure out syntax and storage for calling other functions, especially for async APIs.

### Ruleset
A ruleset is an object that defines a *getRule* function.  Calling this function may change the internal state of the ruleset, such as annotating which rules were most recently returned, or drawing and removing a rule from a shuffled list of available rules.

#### Basic ruleset
A basic ruleset is just an array of options.

They can be created by raw JSON by having an *array* or a *string* as the value, like this:
"someKey":["rule0", "rule1", "some#complicated#rule"]
If there is only one rule, it is acceptable short hand to leave off the array, but this only works with Strings.
"someKey":"just one rule"

These use the default distribution of the Grammar that owns them, which itself defaults to regular stateless pseudo-randomness.

#### Rulesets with conditions, distributions, or ranked fallbacks
### **this feature is under development, coming soon
These rulesets are created when the raw JSON has an *object* rather than an *array* as the value.

Some attributes of this object can be:

* baseRules: a single ruleset,
* ruleRanking: an array of rulesets, call *getRule* on each in order until one returns a value, if none do, return *baseRules*.*getRule*,
* distribution: a new distribution to override the default)
* conditionRule: a rule to expand
* conditionValue: a value to match the expansion against
* conditionSuccess: a ruleset to use if expanding *conditionRule* returns *conditionValue*, otherwise use *baseRules*  


These can be nested, so it is possible to make a ruleset 
## Development

After checking out the repo, run `bin/setup` to install dependencies. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/esmarkowski/tracery-rb. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/esmarkowski/tracery-rb/blob/master/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).


