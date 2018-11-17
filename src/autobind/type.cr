module Autobind::Type
  def self.to_crystal(type : Clang::Type)
    case type.kind
    when .void?              then "Void"
    when .bool?              then "Bool"
    when .char_u?, .u_char?  then "LibC::Char"
    when .char16?, .u_short? then "LibC::Short"
    when .char32?            then "LibC::UInt32"
    when .u_int?             then "LibC::UInt"
    when .u_long?            then "LibC::ULong"
    when .u_long_long?       then "LibC::ULongLong"
    when .w_char?            then "LibC::WChar"
    when .char_s?, .s_char?  then "LibC::Char"
    when .short?             then "LibC::Short"
    when .int?               then "LibC::Int"
    when .long?              then "LibC::Long"
    when .long_long?         then "LibC::LongLong"
    when .float?             then "LibC::Float"
    when .double?            then "LibC::Double"
    when .long_double?       then "LibC::LongDouble"
    when .pointer?           then visit_pointer(type)
    when .enum?, .record?
      spelling = type.cursor.spelling
      spelling = type.spelling if type.cursor.spelling.empty?
      Constant.to_crystal(spelling)
    when .elaborated? then to_crystal(type.named_type)
    when .typedef?
      if (spelling = type.spelling).starts_with?('_')
        to_crystal(type.canonical_type)
      else
        Constant.to_crystal(spelling)
      end
    when .constant_array? then visit_constant_array(type)
      # when .vector? then visit_vector(type)
    when .incomplete_array? then visit_incomplete_array(type)
      # when .variable_array? then visit_variable_array(type)
      # when .dependent_sized_array? then visit_dependent_sized_array(type)
    when .function_proto?    then visit_function_proto(type)
    when .function_no_proto? then visit_function_no_proto(type)
    when .unexposed?         then to_crystal(type.canonical_type)
    else
      raise "unsupported C type: #{type}"
    end
  end

  def self.visit_pointer(type)
    "#{to_crystal type.pointee_type}*"
  end

  def self.visit_constant_array(type)
    "StaticArray(#{to_crystal type.array_element_type}, #{type.array_size})"
  end

  def self.visit_function_proto(type)
    String.build do |str|
      str << '('
      type.arguments.each_with_index do |t, index|
        str << ", " unless index == 0
        str << Type.to_crystal(t)
      end
      str << ") -> "
      str << Type.to_crystal(type.result_type)
    end
  end

  def self.visit_function_no_proto(type)
    raise "# UNSUPPORTED: FunctionNoProto #{type.inspect}"
  end

  def self.visit_incomplete_array(type)
    # element_type = Type.to_crystal(type.array_element_type.canonical_type)
    "#{Type.to_crystal type.array_element_type}*"
  end
end
