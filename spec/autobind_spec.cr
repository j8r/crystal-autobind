require "./spec_helper"

macro assert_binding(header_file)
  it "generates bindings for {{header_file.id}}" do
    parser = Autobind::Parser.new {{header_file}}, ["-I/usr/include"]
    parser.parse
    parser.check.should be_true
  end
end

describe Autobind do
  assert_binding "errno.h"
  assert_binding "fcntl.h"
  assert_binding "syscall.h"
  assert_binding "ulimit.h"
  assert_binding "utime.h"
end
