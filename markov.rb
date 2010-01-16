#!/usr/bin/env ruby

PREFIX_LENGTH = 2
SENTINEL_WORD = "MARKOV_SENTINEL_WORD"
OUTPUT_WORDS = 250

prefix_tab = Hash.new()

data = ""

File.open("data.txt").each do |line|
  data << line
end

words = data.split #(/\s+/)

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
    raise "Error" if @words.length != PREFIX_LENGTH
  end
  
  def to_s
    @words.join " "
  end
  
end

current_prefix = Prefix.new(Array.new(PREFIX_LENGTH, SENTINEL_WORD))

words.each do |word|
  p = Prefix.new(current_prefix.words)
  prefix_tab[p] ||= []
  prefix_tab[p] << word
  current_prefix.rotate word
end

p = Prefix.new(current_prefix.words)
prefix_tab[p] ||= []
prefix_tab[p] << 'nil'

#Generate output
current_prefix = Prefix.new(Array.new(PREFIX_LENGTH, SENTINEL_WORD))

generated = ""

OUTPUT_WORDS.times do
  candidates = prefix_tab[current_prefix]
  next_word = ""
  candidates.each_index do |i|
    next_word = candidates[i] if rand(i + 1) == 0
  end
  generated << next_word << " "
  break if next_word == SENTINEL_WORD
  current_prefix.rotate(next_word)
end

puts generated
