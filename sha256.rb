require './Padding'
require './constants'


def hex_to_binary(hex)
  decimal = hex.to_i(16)
  binary = decimal.to_s(2)
  binary
end

class Sha256
  attr_reader :int_hash_value
  attr_reader :padding
  attr_reader :a
  attr_reader :b
  attr_reader :c
  attr_reader :d
  attr_reader :e
  attr_reader :f
  attr_reader :g
  attr_reader :h

  def initialize(binary_in)
    @int_hash_value = []
    @binary_in = binary_in
    @padding = Padding.new(binary_in)
    @padding.compute()
  end

  def hash
    return nil unless int_hash_value == []
    
    for i in 0..7
      @int_hash_value << ARR_H[i]
    end

    chunked_data = @padding.output.each_slice(512)
    chunked_data.each_with_index do |chunk, index|
      @a = @int_hash_value[0].clone
      @b = @int_hash_value[1].clone
      @c = @int_hash_value[2].clone
      @d = @int_hash_value[3].clone
      @e = @int_hash_value[4].clone
      @f = @int_hash_value[5].clone
      @g = @int_hash_value[6].clone
      @h = @int_hash_value[7].clone

      add_more_48_words(chunk)
      arr_32_bit = chunk.each_slice(32).to_a
      create_message_schedule(arr_32_bit)
      create_compression(arr_32_bit)
    end

    @int_hash_value.map(&:join).map {|i| i.to_i(2)}.map {|i| i.to_s(16)}.join()
  end

  private

  def create_compression arr
    for i in 0..63
      # S1 = (e rightrotate 6) xor (e rightrotate 11) xor (e rightrotate 25)
      # ch = (e and f) xor ((not e) and g)
      # temp1 = h + S1 + ch + k[i] + w[i]
      # S0 = (a rightrotate 2) xor (a rightrotate 13) xor (a rightrotate 22)
      # maj = (a and b) xor (a and c) xor (b and c)
      # temp2 := S0 + maj
      # h = g
      # g = f
      # f = e
      # e = d + temp1
      # d = c
      # c = b
      # b = a
      # a = temp1 + temp2

      s1 = xor(xor(right_rotate(e, 6), right_rotate(e, 11)), right_rotate(e, 25))
      ch = xor(bit_and(e, f), bit_and(bit_not(e), g))
      temp1 = sum_bit_arrays(sum_bit_arrays(sum_bit_arrays(sum_bit_arrays(h, s1), ch), ARR_K[i]), arr[i])
      s0 = xor(xor(right_rotate(a, 2), right_rotate(a, 13)), right_rotate(a, 22))
      maj = xor(xor(bit_and(a, b), bit_and(a, c)), bit_and(b, c))
      temp2 = sum_bit_arrays(s0, maj)

      @h = @g
      @g = @f
      @f = @e
      @e = sum_bit_arrays(d, temp1).last(32)
      @d = @c
      @c = @b
      @b = @a
      @a = sum_bit_arrays(temp1, temp2).last(32)
    end

    @int_hash_value[0] = sum_bit_arrays(a,  @int_hash_value[0]).last(32)
    @int_hash_value[1] = sum_bit_arrays(b,  @int_hash_value[1]).last(32)
    @int_hash_value[2] = sum_bit_arrays(c,  @int_hash_value[2]).last(32)
    @int_hash_value[3] = sum_bit_arrays(d,  @int_hash_value[3]).last(32)
    @int_hash_value[4] = sum_bit_arrays(e,  @int_hash_value[4]).last(32)
    @int_hash_value[5] = sum_bit_arrays(f,  @int_hash_value[5]).last(32)
    @int_hash_value[6] = sum_bit_arrays(g,  @int_hash_value[6]).last(32)
    @int_hash_value[7] = sum_bit_arrays(h,  @int_hash_value[7]).last(32)
  end

  def create_message_schedule arr_32_bit
    for i in 16..63
      # s0 = (w[i-15] rightrotate 7) xor (w[i-15] rightrotate 18) xor (w[i-15] rightshift 3)
      # s1 = (w[i- 2] rightrotate 17) xor (w[i- 2] rightrotate 19) xor (w[i- 2] rightshift 10)
      # w[i] = w[i-16] + s0 + w[i-7] + s1
      s0 = xor(xor(right_rotate(arr_32_bit[i-15], 7), right_rotate(arr_32_bit[i-15], 18)), right_shift(arr_32_bit[i-15], 3))
      s1 = xor(xor(right_rotate(arr_32_bit[i-2], 17), right_rotate(arr_32_bit[i-2], 19)), right_shift(arr_32_bit[i-2], 10))
      
      w = sum_bit_arrays(sum_bit_arrays(sum_bit_arrays(arr_32_bit[i-16], s0), arr_32_bit[i-7]), s1)
      arr_32_bit[i] = w.last(32)
    end
  end

  def sum_bit_arrays arr1, arr2
    arr1 = arr1.clone
    arr2 = arr2.clone

    # Ensure that 2 arrays have the same length
    max_length = [arr1.length, arr2.length].max
    arr1 = [0] * (max_length - arr1.length) + arr1
    arr2 = [0] * (max_length - arr2.length) + arr2

    result = []
    carry = 0
  
    (max_length - 1).downto(0) do |i|
      sum = arr1[i] + arr2[i] + carry
      result.unshift(sum % 2)
      carry = sum / 2
    end
  
    result.unshift(carry) if carry > 0
  
    result
  end

  def xor arr1, arr2
    arr1.clone.zip(arr2.clone).map { |bit1, bit2| bit1 ^ bit2 }
  end

  def bit_and arr1, arr2
    arr1.clone.zip(arr2.clone).map { |bit1, bit2| bit1 & bit2 }
  end

  def bit_not arr
    arr.clone.map { |bit| bit == 1 ? 0 : 1 }
  end

  def right_rotate array, n
    array[-n..-1] + array[0...-n]
  end

  def right_shift arr, n
    arr = arr.clone
    n.times { arr.unshift(0) }
    arr.pop(n)
    
    arr
  end

  def add_more_48_words chunk
    (48*32).times { chunk << 0 }
  end
end