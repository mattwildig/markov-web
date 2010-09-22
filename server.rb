require 'rubygems'
require 'sinatra'
require 'haml'
require 'lib/markov'
require 'lib/data'

begin
  require 'ext/Markov'
  @@native_available = true
rescue LoadError
  puts "Native implementation not available"
  @@native_available = false
end

MAX_WORDS = 1000
DEFAULT_WORDS = 600

# set :haml, {:format => :html5 }

# class Time
#   def total_usec
#     to_i * 1000000 + usec
#   end
# end


before do
  request.env['PATH_INFO'] = '/' if request.env['PATH_INFO'].empty?
end

get '/' do
  
  numwords = params['numwords'] ? params['numwords'].to_i : DEFAULT_WORDS
  numwords = numwords >= 0 ? numwords : DEFAULT_WORDS
  numwords = [numwords, MAX_WORDS].min
    
  if @@native_available
    @native = params['impl'] == 'native'
    @native_available = true
  else
    @native = false
  end
  
  impl = @native ? Markov::ChainNative : Markov::Chain
  
  if params['data']
    files = params['data'].collect do |s|
      begin
        File.new(File.join('data', "#{s}.txt" ))
      rescue Errno::ENOENT
        nil
      end
    end
    
    files.compact!
    
    start = Time.new
    @txt = impl.new(files, :output_words => numwords).generate
    final = Time.new
    
    files.each{|f| f.close}
    
    # @usec = final.total_usec - start.total_usec
    @time = final.to_f - start.to_f
  end
  haml :index
end