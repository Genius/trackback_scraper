module StringHelper
  extend self

  def coerce_to_utf8(input)
    output = input.dup.force_encoding("UTF-8")

    return output if output.valid_encoding?

    output = output.force_encoding("BINARY")
    output.encode("UTF-8", invalid: :replace, undef: :replace)
  end
end
