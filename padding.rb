class Padding
  attr_accessor :binary_in, :output

  def initialize(binary_in)
    @binary_in = binary_in
    @output = []
  end

  def compute
    if @binary_in == nil then
      return nil
    end

    # l + 1 + k ≡ 448 mod 512
    # => l + k ≡ 447 mod 512
    original_length = @binary_in.length
    k = (447 - original_length)%512
    puts "k is #{k}"

    @output = @binary_in.split("").map(&:to_i)
    @output << 1
    k.times { @output << 0 }
    @output += [original_length].pack("Q>").unpack1("B*").split("").map(&:to_i)
  end
end