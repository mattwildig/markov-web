#!/usr/bin/env ruby
module Markov
  DEFAULT_PREFIX_LENGTH = 2
  DEFAULT_SENTINEL_WORD = "MARKOV_SENTINEL_WORD"
  DEFAULT_OUTPUT_WORDS = 250

  class Chain
    
    def initialize(input, options = {})
      
      @prefix_length = options[:prefix_length] || DEFAULT_PREFIX_LENGTH
      @sentinel = options[:sentinel] || DEFAULT_SENTINEL_WORD
      @output_words = options[:output_words] || DEFAULT_OUTPUT_WORDS
      
      @prefix_tab = Hash.new()
      
      if input.respond_to? :read
        words = input.read.split
      elsif input.kind_of? String
        words = File.read(input).split
      else
        raise "Unknown input type for Markov generation: #{input.class}"
      end
      
      current_prefix = Prefix.new(Array.new(@prefix_length, @sentinel))
      
      words.each do |word|
        p = Prefix.new(current_prefix.words)
        @prefix_tab[p] ||= []
        @prefix_tab[p] << word
        current_prefix.rotate word
      end
      
      p = Prefix.new(current_prefix.words)
      @prefix_tab[p] ||= []
      @prefix_tab[p] << @sentinel
      
    end
    
    def generate(number_words = @output_words)
      current_prefix = Prefix.new(Array.new(@prefix_length, @sentinel))

      generated = ""

      number_words.times do
        candidates = @prefix_tab[current_prefix]
        next_word = ""
        candidates.each_index do |i|
          next_word = candidates[i] if rand(i + 1) == 0
        end
        break if next_word == @sentinel
        generated << next_word << " "
        current_prefix.rotate(next_word)
      end

      puts generated
    end
    
    def to_s
     "Markov::Chain - #{@prefix_tab.length} entries"
    end
    
    def inspect
      to_s
    end
    
  end

  class Prefix
  
    attr :words
  
    def initialize(words)
      @words = Array.new words
    end
  
    def hash
      @words.inject{|a,b| a + b}.hash
    end
  
    def eql?(other)
      @words.each_index do |i|
        return false if @words[i] != other.words[i]
      end
      true
    end
  
    def rotate(word)
      @words.shift
      @words << word
    end
  
    def to_s
      @words.join " "
    end
  
  end

end