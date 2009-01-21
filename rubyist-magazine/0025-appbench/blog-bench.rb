## database information
$HOST = 'localhost'
$USER = 'user1'
$PASS = 'pass1'
$DB   = 'example1'

## ----------------------------------------

require "rubygems"
require "erubis"
require "cgiext"
require "mysql"
require "motto_mysql"
require "benchmark"

## class definition
class ModelObject
end

class BlogUser < ModelObject
  attr_accessor :id, :name, :email, :password, :created_at, :updated_at
end

class BlogEntry < ModelObject
  attr_accessor :id, :user_id, :title, :body, :password, :created_at, :updated_at
  attr_accessor :user, :comments
  def comments
    @comments ||= []
  end
end

class BlogComment < ModelObject
  attr_accessor :id, :entry_id, :user, :uri, :body, :created_at, :deleted_at
  attr_accessor :entry
end

## options provided by '-s'
$N = ENV['N'] unless defined?($N)       # number to repeat
$e = ENV['E'] unless defined?($e)       # escape html or not
$L = ENV['L'] unless defined?($L)
$N = ($N || 10).to_i
$L = ($L || 10).to_i
$e = $e == 'false' ? false : true

## view template
filename = "blog-bench.rhtml"
str = File.read(filename)
escape = $e ? true : false
eruby = Erubis::FastEruby.new(str, :filename=>filename, :escape=>escape)
#def h(val)
#  Erubis::XmlHelper.escape_xml(val)
#end
include Erubis::XmlHelper

## "sql injection"? what's that?
USERS_SQL = <<END
select * from blog_users order by id;
END
ENTRIES_SQL = <<END
select blog_entries.* from blog_entries, blog_users
where blog_entries.user_id = blog_users.id
  and blog_users.name = '%s'
order by blog_entries.id desc
limit 0, #{$L}
END
COMMENTS_SQL = <<END
select * from blog_comments
where entry_id = %s
order by id
END
COMMENTS_SQL2 = <<END
select * from blog_comments
where entry_id in (%s)
order by id
END

## entries
def get_entries_by_user_name(conn, user_name)
  result = conn.query(ENTRIES_SQL % user_name)
  entries = result.fetch_all_as(BlogEntry)
  if false
    entries.each do |entry|
      result = conn.query(COMMENTS_SQL % entry.id)
      comments = result.fetch_all_as(BlogComment)
      entry.comments = comments
    end
  else
    entry_ids = entries.collect {|entry| entry.id }
    if entry_ids.empty?
      hash = {}
    else
      result = conn.query(COMMENTS_SQL2 % entry_ids.join(','))
      comments = result.fetch_all_as(BlogComment)
      hash = comments.group_by {|comment| comment.entry_id }
    end
    entries.each do |entry|
      entry.comments = hash[entry.id] || []
    end
  end
  entries
end

## benchmark
output = nil
begin
  conn = Mysql.connect($HOST, $USER, $PASS, $DB)
  result = conn.query(USERS_SQL)
  users = result.fetch_all_as(BlogUser)
  Benchmark.bm do |r|
    r.report do
      $N.times do |i|
        users.each do |user|
          entries = get_entries_by_user_name(conn, user.name)
          output = eruby.evaluate(:user=>user, :entries=>entries)
        end
      end
    end
  end
ensure
  conn.close unless conn.nil?
end

print output if $DEBUG || ENV['DEBUG']
