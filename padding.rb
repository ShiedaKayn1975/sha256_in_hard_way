class Padding
  LENGTH_INITIAL_DATA_IN_BIT = 64
  attr_accessor :binary_in, :output, :num_blocks

  def initialize(binary_in)
    @binary_in = binary_in
    @output = []
    @num_blocks = nil
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

    @num_blocks = (original_length + 1 + k + LENGTH_INITIAL_DATA_IN_BIT)/512

    @output = @binary_in.split("").map(&:to_i)
    @output << 1
    k.times { @output << 0 }
    @output += [original_length].pack("Q>").unpack1("B*").split("").map(&:to_i)
  end
end