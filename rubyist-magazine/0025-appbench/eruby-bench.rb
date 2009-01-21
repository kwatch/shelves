## options provided by '-s'
$N = ENV['N'] unless defined?($N)       # number to repeat
$e = ENV['E'] unless defined?($e)       # escape html or not
$cgiext = nil unless defined?($cgiext)  # require 'cgiext' or not

## compile view template
require 'rubygems'
require 'erubis'
filename = "eruby-bench.rhtml"
str = File.read(filename)
escape = $e ? true : false
eruby = Erubis::FastEruby.new(str, :escape=>escape)
src = eruby.src
eval "def render(list); #{src}; end", binding(), filename

## load test data
class StockInfo
  attr_accessor :name, :url, :symbol      # string
  attr_accessor :price, :change, :ratio   # float
end
require "yaml"
data = YAML.load_file("eruby-data.yaml")
list = []
data["list"].each do |hash|
  item = StockInfo.new
  item.name   = hash['name']
  item.url    = hash['url']
  item.symbol = hash['symbol']
  item.price  = hash['price']
  item.change = hash['change']
  item.ratio  = hash['ratio']
  list << item
end

## preparation
require "cgiext" if $cgiext
$N = ($N || 100000).to_i
if $N == 1
  print render(list)
  exit
end

## do benchmark
require "benchmark"
Benchmark.bm do |r|
  r.report do
    $N.times { render(list) }
  end
end
