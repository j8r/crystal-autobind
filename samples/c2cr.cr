require "./c2cr/parser"

#  /usr/include
#  /usr/lib/llvm-5.0/include
#  /usr/lib/llvm-5.0/lib/clang/5.0.0/include # C++
options = ["-I/usr/include"]
header = nil

i = -1
while arg = ARGV[i += 1]?
  case arg
  when "-I", "-D"
    options << "#{options}#{ARGV[i += 1]}"
  when .starts_with?("-I"), .starts_with?("-D")
    options << arg
  when .ends_with?(".h")
    header = arg
  else
    puts "Unknown option: #{arg}"
  end
end

parser = C2CR::Parser.new(header.not_nil!, options)

puts "lib LibC"
parser.parse
puts "end"