class Integer
  def prime?
    return false if self < 2
    2.upto(pred).all? { |divisor| remainder(divisor).nonzero? }
  end

  def prime_factors
    return [] if abs == 1
    divisor = 2.upto(abs).find { |x| x.prime? and abs.remainder(x).zero? }
    [divisor] + (abs / divisor).prime_factors
  end

  def harmonic
    1.upto(self).reduce { |sum, number| sum + Rational(1, number) }.to_r
  end

  def digits
    abs.to_s.chars.map(&:to_i)
  end
end

class Array
  def frequencies
    each_with_object Hash.new(0) do |value, result|
      result[value] += 1
    end
  end

  def average
    reduce(:+).fdiv(count) unless empty?
  end

  def drop_every(n)
    each_slice(n).flat_map { |slice| slice.take(n - 1) }
  end

  def combine_with(other)
    empty? ? other : [first] + other.combine_with(self[1..-1])
  end
end
