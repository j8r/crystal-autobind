require "./spec_helper"

describe Autobind do
  {% for header in %w(errno.h) %}
  it "generates bindings for {{header.id}}" do
    parser = Autobind::Parser.new {{header}}, ["-I/usr/include"]
    parser.parse
    check = parser.check
    parser.check.should be_true
  end
  {% end %}
end
