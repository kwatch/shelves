## database information
$HOST = 'localhost'
$USER = 'user1'
$PASS = 'pass1'
$DB   = 'example1'

## ----------------------------------------

## options provided by '-s'
$N = ENV['N'] unless defined?($N)       # number to repeat
$L = ENV['L'] unless defined?($L)       # length of blog entries
$N = ($N || 100).to_i
$L = ($L || 10).to_i
$escape  = !defined?($unescape)
$join    = !defined?($nojoin)
$wherein = !defined?($nowherein)

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
eruby = Erubis::FastEruby.new(str, :filename=>filename, :escape=>$escape)
include Erubis::XmlHelper
alias h escape_xml

## SQL statements
USERS_SQL = <<END
select * from blog_users order by id;
END
USERS_SQL2 = <<END
select * from blog_users where name = ?;
END
ENTRIES_SQL = <<END
select blog_entries.* from blog_entries, blog_users
where blog_entries.user_id = blog_users.id
  and blog_users.name = ?
order by blog_entries.id desc
limit 0, #{$L}
END
ENTRIES_SQL2 = <<END
select * from blog_entries
where blog_entries.user_id = ?
order by blog_entries.id desc
limit 0, #{$L}
END
COMMENTS_SQL = <<END
select * from blog_comments
where entry_id in (%s)
order by id
END
COMMENTS_SQL2 = <<END
select * from blog_comments
where entry_id = ?
order by id
END




if $useindex
  [ENTRIES_SQL, ENTRIES_SQL2].each {|sql| sql.sub!(/from blog_entries/, '\& use index (primary)') }
end


## helper method for Mysql object
class Mysql
  def query_one(sql, *args)
    stmt = self.prepare(sql)
    stmt.execute(*args)
    row = stmt.fetch
    ret = block_given? ? yield(row) : row
    stmt.free_result()
    ret
  end
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



## entries and comments
def get_entries_by_user_name(conn, user_name)
  ## entries
  #entries = conn.query(ENTRIES_SQL % user_name).fetch_all_as(BlogEntry)
  if $join
    entries = conn.query_all(ENTRIES_SQL, user_name) {|row| BlogEntry.new(*row) }
  else
    user = conn.query_one(USERS_SQL2, user_name) {|row| BlogUser.new(*row) }
    entries = conn.query_all(ENTRIES_SQL2, user.id) {|row| BlogEntry.new(*row) }
  end
  ## comments
  if $wherein
    entry_ids = entries.collect {|entry| entry.id }
    if entry_ids.empty?
      hash = {}
    else
      #comments = conn.query(COMMENTS_SQL2 % entry_ids.join(',')).fetch_all_as(BlogComment)
      sql = COMMENTS_SQL % entry_ids.join(',')
      comments = conn.query_all(sql) {|row| BlogComment.new(*row) }
      hash = comments.group_by {|comment| comment.entry_id }
    end
    entries.each do |entry|
      entry.comments = hash[entry.id] || []
    end
  else
    entries.each do |entry|
      #comments = conn.query(COMMENTS_SQL % entry.id).fetch_all_as(BlogComment)
      comments = conn.query_all(COMMENTS_SQL2, entry.id) {|row| BlogComment.new(*row) }
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
