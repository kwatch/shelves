## database information
$HOST = 'localhost'
$USER = 'user1'
$PASS = 'pass1'
$DB   = 'example1'

## ----------------------------------------

## options provided by '-s'
$N = ENV['N'] unless defined?($N)       # number to repeat
$e = ENV['E'] unless defined?($e)       # escape html or not
$L = ENV['L'] unless defined?($L)       # length of blog entries
$N = ($N || 100).to_i
$L = ($L || 10).to_i
$e = $e == 'false' ? false : true

##
require "rubygems"
require "erubis"
require "cgiext" if defined?($cgialt)
require "mysql"
#require "motto_mysql"
require "benchmark"

## class definition
class ModelObject
  def self.columns(*attrs)
    attrs.push(:updated_at, :created_at, :deleted_at)
    args = attrs.collect {|attr| "#{attr}=nil" }.join(", ")
    s = "def initialize(#{args})\n"
    attrs.each {|attr| s << "  @#{attr} = #{attr}\n" }
    s << "end\n"
    s << "attr_accessor " << attrs.collect {|attr| ":#{attr}" }.join(', ')
    self.class_eval(s)
  end
end

class BlogUser < ModelObject
  columns :id, :name, :email, :password
end

class BlogEntry < ModelObject
  columns :id, :user_id, :title, :body
  attr_accessor :user, :comments
  def comments
    @comments ||= []
  end
end

class BlogComment < ModelObject
  columns :id, :entry_id, :user, :uri, :body
  attr_accessor :entry
end

## view template
filename = "blog-bench.rhtml"
str = File.read(filename)
escape = $e ? true : false
eruby = Erubis::FastEruby.new(str, :filename=>filename, :escape=>escape)
#def h(val)
#  Erubis::XmlHelper.escape_xml(val)
#end
include Erubis::XmlHelper

## SQL statements
USERS_SQL = <<END
select * from blog_users order by id;
END
ENTRIES_SQL = <<END
select blog_entries.* from blog_entries, blog_users
where blog_entries.user_id = blog_users.id
  and blog_users.name = ?
order by blog_entries.id desc
limit 0, #{$L}
END
COMMENTS_SQL = <<END
select * from blog_comments
where entry_id = ?
order by id
END
COMMENTS_SQL2 = <<END
select * from blog_comments
where entry_id in (%s)
order by id
END
#COMMENTS_SQL2 = <<END
#select id, entry_id, user, uri, body, created_at from blog_comments
#where entry_id in (%s)
#order by id
#END

## helper method for Mysql object
class Mysql
  def query_all(sql, *args)
    stmt = self.prepare(sql)
    stmt.execute(*args)
    arr = []
    stmt.each {|row| arr << yield(row) }
    #while (row = stmt.fetch()); yield(row); end
    stmt.free_result()
    arr
  end
end



## entries
def get_entries_by_user_name(conn, user_name)
  #entries = conn.query(ENTRIES_SQL % user_name).fetch_all_as(BlogEntry)
  entries = conn.query_all(ENTRIES_SQL, user_name) {|row| BlogEntry.new(*row) }
  if false
    entries.each do |entry|
      #comments = conn.query(COMMENTS_SQL % entry.id).fetch_all_as(BlogComment)
      comments = conn.query_all(COMMENTS_SQL, entry.id) {|row| BlogComment.new(*row) }
    end
  else
    entry_ids = entries.collect {|entry| entry.id }
    if entry_ids.empty?
      hash = {}
    else
      #comments = conn.query(COMMENTS_SQL2 % entry_ids.join(',')).fetch_all_as(BlogComment)
      sql = COMMENTS_SQL2 % entry_ids.join(',')
      comments = conn.query_all(sql) {|row| BlogComment.new(*row) }
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
  #users = conn.query(USERS_SQL).fetch_all_as(BlogUser)
  users = conn.query_all(USERS_SQL) {|row| BlogUser.new(*row) }
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
