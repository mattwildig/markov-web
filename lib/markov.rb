#!/usr/bin/env ruby
module Markov
  
  DEFAULT_OPTIONS = {
    :prefix_length => 2,
    :sentinel => "MARKOV_SENTINEL_WORD",
    :output_words => 250,
    :show_branches => false }

  class Chain
    
    def initialize(*inputs)
      
      opts = inputs.last.kind_of?(Hash) ? inputs.pop : {}
      @options = DEFAULT_OPTIONS.merge(opts)
      
      @prefix_tab = Hash.new {|hash, key| hash[Array.new(key)] = []}
      
      inputs.each do |input|
        if input.kind_of? Array
          input.each{|i| parse i}
        else
          parse input
        end
      end
    end
    
    def parse (input)
      current_prefix = Array.new(@options[:prefix_length], @options[:sentinel])
      
      if input.respond_to? :read
        words = input.read.split
      elsif input.kind_of? String
        words = File.read(input).split
      else
        raise "Unknown input type for Markov generation: #{input.class}"
      end
      
      words.each do |word|
        @prefix_tab[current_prefix] << word
        (current_prefix << word).shift
      end
      
      @prefix_tab[current_prefix] << @options[:sentinel]
      
    end
    
    def generate(number_words = @options[:output_words])
      current_prefix = Array.new(@options[:prefix_length], @options[:sentinel])

      generated = ""

      number_words.times do
        candidates = @prefix_tab[current_prefix]
        generated << "-(#{candidates.length})- " if @options[:show_branches]
        next_word = candidates[rand(candidates.length)]
        break if next_word == @options[:sentinel]
        generated << next_word << " "
        (current_prefix << next_word).shift
      end
      generated
    end
    
    def stream(out=$sysout, number_words = @options[:output_words])
      out.puts(generate(number_words))
    end
    
    def to_s
     "Markov::Chain - #{@prefix_tab.length} entries"
    end
    
  end

  if __FILE__ == $0
    Chain.new(ARGF).generate
  end

end
