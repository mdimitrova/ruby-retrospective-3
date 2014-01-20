class Integer
  def prime?
    return false if self < 2

    upper_limit = Math.sqrt(self)
    (2..upper_limit).all? { |i| remainder(i).nonzero? }
  end

  def prime_factor?(number)
    number.prime? and remainder(number).zero?
  end

  def prime_factors # FIXME
    factors = []
    number = self.abs
    while number > 1
      (2..number).each do |i|
       number.prime_factor? i and factors << i and number /= i
      end
    end
    factors.sort
  end

  def harmonic
    sum = 0
    (1..self).each { |n| sum += Rational(1, n) }
    sum
  end

  def digits
    number = self.abs
    digits = []
    while number > 0
      digits << number % 10
      number /= 10
    end
    digits.reverse
  end
end

class Array
  def frequencies
    frequencies = Hash.new(0)
    (0...length).each do |i|
      if frequencies.key?(self[i])
        frequencies[self[i]] += 1
      else
        frequencies[self[i]] = 1
      end
    end
    frequencies
  end

  def average
    return if empty?
    reduce(:+).fdiv(count)
  end

  def drop_every(n)
    reduced_array = []
    each_with_index do |item, i|
      reduced_array << item if (i + 1).remainder(n).nonzero?
    end
    reduced_array
  end

  def combine_with(other)
    combined = []
    max_length = [length, other.length].max
    (0...max_length).each do |i|
      combined << self[i] if i < length
      combined << other[i] if i < other.length
    end
    combined
  end
end
