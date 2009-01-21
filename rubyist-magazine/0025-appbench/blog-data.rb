###
### usage:
###    ruby blog-data.rb > blog-data.sql
###    mysql -p -u username dbname < blog-data.sql
###

### create tables
puts <<END
drop table if exists blog_users;
create table blog_users (
  id          integer         primary key auto_increment,
  name        varchar(32)     not null unique,
  password    varchar(32)     not null,
  email       varchar(64)     not null,
  created_at  datetime        not null,
  updated_at  datetime        not null,
  index blog_users_email(email)
);

drop table if exists blog_entries;
create table blog_entries(
  id          integer         primary key auto_increment,
  user_id     integer         not null references blog_users(id),
  title       varchar(200)    not null,
  body        text(4000)      not null,
  created_at  datetime        not null,
  updated_at  datetime        not null,
  index blog_entries_user_id(user_id)
);

drop table if exists blog_comments;
create table blog_comments(
  id          integer         primary key auto_increment,
  entry_id    integer         not null references blog_entries(id),
  user        varchar(32)     not null,
  uri         varchar(128)    ,
  body        text(1000)      not null,
  created_at  datetime        not null,
  deleted_at  datetime        ,
  index blog_comments_entry_id(entry_id)
);

END


### users
puts "-- users"
require 'digest/md5'
n_users = 50
(1..n_users).each do |i|
  name = "user%03d" % i
  email = "#{name}@mail.com"
  password = Digest::MD5.hexdigest("password%03d" % i)
  ts = "2000-01-01 12:34:56"
  puts "insert into blog_users values(null, '#{name}', '#{email}', '#{password}', '#{ts}', '#{ts}');"
end

### entries
puts "-- entries"
t = Time.mktime(2000, 1, 1)
n_entries_per_user = 1000
body = DATA.read().gsub(/\r?\n/, ' ')
(1..n_entries_per_user).each do |i|
  t2 = t.dup
  (1..n_users).each do |user_id|
    t += 10
    title = "Title #{user_id}-#{i}"
    ts = t.strftime("%Y-%m-%d %H:%M:%S")
    puts "insert into blog_entries values(null, #{user_id}, '#{title}', '#{body}', '#{ts}', '#{ts}');"
  end
  t = t2.dup + 60 * 60 * 24
end

### comments
puts "-- comments"
n_entries = n_users * n_entries_per_user
(1..n_entries).each do |entry_id|
  user = "name#{entry_id}"
  uri  = "http://www.#{user}.com/"
  body = "comment-#{entry_id}"
  ts   = t.strftime("%Y-%m-%d %H:%M:%S")
  puts "insert into blog_comments values (null, #{entry_id}, '#{user}', '#{uri}', '1-#{body}', '#{ts}', '#{ts}');"
  t += 30
  puts "insert into blog_comments values (null, #{entry_id}, '#{user}', '#{uri}', '2-#{body}', '#{ts}', '#{ts}');"
  t += 30
end


__END__
<p>
AAAAAAAAAA
AAAAAAAAAA
AAAAAAAAAA
</p>
<p>
BBBBBBBBBB
BBBBBBBBBB
BBBBBBBBBB
</p>
<p>
CCCCCCCCCC
CCCCCCCCCC
CCCCCCCCCC
</p>
<p>
DDDDDDDDDD
DDDDDDDDDD
DDDDDDDDDD
</p>
<p>
EEEEEEEEEE
EEEEEEEEEE
EEEEEEEEEE
</p>
