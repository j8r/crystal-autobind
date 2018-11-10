require "./autobind/constant"
require "./autobind/parser"
require "./autobind/type"

cflags = [] of String
header = ""
remove_enum_prefix = remove_enum_suffix = false
lib_name = "LibC"
mod_name = nil
Help = <<-USAGE
usage : autobind [--help] [options] <header.h>

Some available options are:
    -I<directory>   Adds directory to search path for include files
    -D<name>        Adds an implicit #define

In addition, the CFLAGS environment variable will be used, so you may set it
up before compilation when search directories, defines, and other options
aren't fixed and can be dynamic.

The following options control how enum constants are cleaned up. By default
the value is false (no cleanup), whereas true will remove matching patterns,
while a fixed value will remove just that:
    --remove-enum-prefix[=true,false,<value>]
    --remove-enum-suffix[=true,false,<value>]

The resulting library name can be controlled with the --lib-name argument,
and it can be wrapped in a parent module with --module-name.
    --lib-name="LibC"         (the default)
    --parent-module="Library"
If no module is specified, the resulting code is not wrapped in a parent
module. If the library name is not specified, it will be called "LibC".
USAGE
USAGE_EXIT_CODE = 64

if arg = ENV["CFLAGS"]?
  cflags += arg.split(' ').reject(&.empty?)
end

until ARGV.empty?
  case arg = ARGV.shift
  when "-I", "-D"
    if value = ARGV[1]?
      cflags << value
    else
      abort "fatal : missing value for #{arg}\n#{Help}", USAGE_EXIT_CODE
    end
  when .starts_with?("-I"), .starts_with?("-D")
    cflags << arg
  when .ends_with?(".h")
    abort "FATAL: you can only specify one header\n#{Help}", USAGE_EXIT_CODE unless header.empty?
    header = arg
  when "--remove-enum-prefix"
    remove_enum_prefix = true
  when .starts_with?("--remove-enum-prefix=")
    case value = arg[21..-1]
    when "", "false" then remove_enum_prefix = false
    when "true"      then remove_enum_prefix = true
    else                  remove_enum_prefix = value
    end
  when "--remove-enum-suffix"
    remove_enum_suffix = true
  when .starts_with?("--remove-enum-suffix=")
    case value = arg[21..-1]
    when "", "false" then remove_enum_suffix = false
    when "true"      then remove_enum_suffix = true
    else                  remove_enum_suffix = value
    end
  when .starts_with? "--lib-name"
    abort "Only one library name can be specified", USAGE_EXIT_CODE unless lib_name == "LibC"
    if arg.includes? '='
      lib_name = arg[11..-1]
    elsif name = ARGV[1]?
      lib_name = name
    else
      abort "FATAL: library name argument was specified but no value was received.\n#{Help}", USAGE_EXIT_CODE
    end
  when .starts_with? "--parent-module"
    abort "FATAL: only one module name can be specified", USAGE_EXIT_CODE if mod_name
    err_str = "FATAL: module name argument was specified but no value was received."
    if arg.includes? '='
      mod_name = arg[16..-1]
      abort err_str + '\n' + Help, USAGE_EXIT_CODE if mod_name.empty?
    else
      mod_name = ARGV[1]? || abort err_str + '\n' + Help, USAGE_EXIT_CODE
    end
  when "--help", "-h"
    STDERR.puts Help
    exit 0
  else
    abort "FATAL: Unknown option: #{arg}\n#{Help}", USAGE_EXIT_CODE
  end
end

Clang.default_c_include_directories cflags

abort "FATAL: no header to create bindings for.\n#{Help}", USAGE_EXIT_CODE if header.empty?

parser = Autobind::Parser.new(
  header,
  cflags,
  remove_enum_prefix: remove_enum_prefix,
  remove_enum_suffix: remove_enum_suffix,
  name: lib_name,
  module_name: mod_name # <-- possibly nil
)

parser.parse
puts parser.libc_output
check = parser.check
abort check if check != true
