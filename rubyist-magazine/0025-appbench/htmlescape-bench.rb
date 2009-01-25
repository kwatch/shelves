
##
## usage: ruby -s htmlescape-ench.rb [-N=100000]
##

begin
  require "rubygems"
rescue LoadError => ignore
end
require "erb"
require "erubis"

s1 = (b1 = "abcde") * 10    # non-HTML string
s2 = (b2 = "<A&B>") * 10    # HTML string
d1 = 12345
f1 = 3.14

N = ($N || ENV['N'] || 100000).to_i / 20

require "benchmark"
Benchmark.bm(30) do |r|

  GC.start()
  r.report("ERB::Util.h(#{b1.inspect})") do
    N.times do
      ERB::Util.h(s1); ERB::Util.h(s1);
      ERB::Util.h(s1); ERB::Util.h(s1);
      ERB::Util.h(s1); ERB::Util.h(s1);
      ERB::Util.h(s1); ERB::Util.h(s1);
      ERB::Util.h(s1); ERB::Util.h(s1);
      ERB::Util.h(s1); ERB::Util.h(s1);
      ERB::Util.h(s1); ERB::Util.h(s1);
      ERB::Util.h(s1); ERB::Util.h(s1);
      ERB::Util.h(s1); ERB::Util.h(s1);
      ERB::Util.h(s1); ERB::Util.h(s1);
    end
  end

  GC.start()
  r.report("Erubis::escape_xml(#{b1.inspect})") do
    N.times do
      Erubis::XmlHelper.escape_xml(s1); Erubis::XmlHelper.escape_xml(s1);
      Erubis::XmlHelper.escape_xml(s1); Erubis::XmlHelper.escape_xml(s1);
      Erubis::XmlHelper.escape_xml(s1); Erubis::XmlHelper.escape_xml(s1);
      Erubis::XmlHelper.escape_xml(s1); Erubis::XmlHelper.escape_xml(s1);
      Erubis::XmlHelper.escape_xml(s1); Erubis::XmlHelper.escape_xml(s1);
      Erubis::XmlHelper.escape_xml(s1); Erubis::XmlHelper.escape_xml(s1);
      Erubis::XmlHelper.escape_xml(s1); Erubis::XmlHelper.escape_xml(s1);
      Erubis::XmlHelper.escape_xml(s1); Erubis::XmlHelper.escape_xml(s1);
      Erubis::XmlHelper.escape_xml(s1); Erubis::XmlHelper.escape_xml(s1);
      Erubis::XmlHelper.escape_xml(s1); Erubis::XmlHelper.escape_xml(s1);
    end
  end

  GC.start()
  r.report("ERB::Util.h(#{b2.inspect})") do
    N.times do
      ERB::Util.h(s2); ERB::Util.h(s2);
      ERB::Util.h(s2); ERB::Util.h(s2);
      ERB::Util.h(s2); ERB::Util.h(s2);
      ERB::Util.h(s2); ERB::Util.h(s2);
      ERB::Util.h(s2); ERB::Util.h(s2);
      ERB::Util.h(s2); ERB::Util.h(s2);
      ERB::Util.h(s2); ERB::Util.h(s2);
      ERB::Util.h(s2); ERB::Util.h(s2);
      ERB::Util.h(s2); ERB::Util.h(s2);
      ERB::Util.h(s2); ERB::Util.h(s2);
    end
  end

  GC.start()
  r.report("Erubis::escape_xml(#{b2.inspect})") do
    N.times do
      Erubis::XmlHelper.escape_xml(s2); Erubis::XmlHelper.escape_xml(s2);
      Erubis::XmlHelper.escape_xml(s2); Erubis::XmlHelper.escape_xml(s2);
      Erubis::XmlHelper.escape_xml(s2); Erubis::XmlHelper.escape_xml(s2);
      Erubis::XmlHelper.escape_xml(s2); Erubis::XmlHelper.escape_xml(s2);
      Erubis::XmlHelper.escape_xml(s2); Erubis::XmlHelper.escape_xml(s2);
      Erubis::XmlHelper.escape_xml(s2); Erubis::XmlHelper.escape_xml(s2);
      Erubis::XmlHelper.escape_xml(s2); Erubis::XmlHelper.escape_xml(s2);
      Erubis::XmlHelper.escape_xml(s2); Erubis::XmlHelper.escape_xml(s2);
      Erubis::XmlHelper.escape_xml(s2); Erubis::XmlHelper.escape_xml(s2);
      Erubis::XmlHelper.escape_xml(s2); Erubis::XmlHelper.escape_xml(s2);
    end
  end

  GC.start()
  r.report("ERB::Util.h(#{f1})") do
    N.times do
      ERB::Util.h(f1); ERB::Util.h(f1);
      ERB::Util.h(f1); ERB::Util.h(f1);
      ERB::Util.h(f1); ERB::Util.h(f1);
      ERB::Util.h(f1); ERB::Util.h(f1);
      ERB::Util.h(f1); ERB::Util.h(f1);
      ERB::Util.h(f1); ERB::Util.h(f1);
      ERB::Util.h(f1); ERB::Util.h(f1);
      ERB::Util.h(f1); ERB::Util.h(f1);
      ERB::Util.h(f1); ERB::Util.h(f1);
      ERB::Util.h(f1); ERB::Util.h(f1);
    end
  end

  GC.start()
  r.report("Erubis::escape_xml(#{f1})") do
    N.times do
      Erubis::XmlHelper.escape_xml(f1); Erubis::XmlHelper.escape_xml(f1);
      Erubis::XmlHelper.escape_xml(f1); Erubis::XmlHelper.escape_xml(f1);
      Erubis::XmlHelper.escape_xml(f1); Erubis::XmlHelper.escape_xml(f1);
      Erubis::XmlHelper.escape_xml(f1); Erubis::XmlHelper.escape_xml(f1);
      Erubis::XmlHelper.escape_xml(f1); Erubis::XmlHelper.escape_xml(f1);
      Erubis::XmlHelper.escape_xml(f1); Erubis::XmlHelper.escape_xml(f1);
      Erubis::XmlHelper.escape_xml(f1); Erubis::XmlHelper.escape_xml(f1);
      Erubis::XmlHelper.escape_xml(f1); Erubis::XmlHelper.escape_xml(f1);
      Erubis::XmlHelper.escape_xml(f1); Erubis::XmlHelper.escape_xml(f1);
      Erubis::XmlHelper.escape_xml(f1); Erubis::XmlHelper.escape_xml(f1);
    end
  end

  GC.start()
  r.report("ERB::Util.h(#{d1})") do
    N.times do
      ERB::Util.h(d1); ERB::Util.h(d1);
      ERB::Util.h(d1); ERB::Util.h(d1);
      ERB::Util.h(d1); ERB::Util.h(d1);
      ERB::Util.h(d1); ERB::Util.h(d1);
      ERB::Util.h(d1); ERB::Util.h(d1);
      ERB::Util.h(d1); ERB::Util.h(d1);
      ERB::Util.h(d1); ERB::Util.h(d1);
      ERB::Util.h(d1); ERB::Util.h(d1);
      ERB::Util.h(d1); ERB::Util.h(d1);
      ERB::Util.h(d1); ERB::Util.h(d1);
    end
  end

  GC.start()
  r.report("Erubis::escape_xml(#{d1})") do
    N.times do
      Erubis::XmlHelper.escape_xml(d1); Erubis::XmlHelper.escape_xml(d1);
      Erubis::XmlHelper.escape_xml(d1); Erubis::XmlHelper.escape_xml(d1);
      Erubis::XmlHelper.escape_xml(d1); Erubis::XmlHelper.escape_xml(d1);
      Erubis::XmlHelper.escape_xml(d1); Erubis::XmlHelper.escape_xml(d1);
      Erubis::XmlHelper.escape_xml(d1); Erubis::XmlHelper.escape_xml(d1);
      Erubis::XmlHelper.escape_xml(d1); Erubis::XmlHelper.escape_xml(d1);
      Erubis::XmlHelper.escape_xml(d1); Erubis::XmlHelper.escape_xml(d1);
      Erubis::XmlHelper.escape_xml(d1); Erubis::XmlHelper.escape_xml(d1);
      Erubis::XmlHelper.escape_xml(d1); Erubis::XmlHelper.escape_xml(d1);
      Erubis::XmlHelper.escape_xml(d1); Erubis::XmlHelper.escape_xml(d1);
    end
  end

end
