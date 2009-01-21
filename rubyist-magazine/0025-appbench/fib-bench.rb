def fib(n)
  n <= 1 ? 1 : fib(n-1) + fib(n-2)
end

$N = (ENV['N'] || $N || 1000).to_i
p fib($N)
