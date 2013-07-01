class TestEnumeration < EnumerateIt::Base
  associate_values(
    :value_1 => ['1', 'Hey, I am 1!'],
    :value_2 => ['2', 'Hey, I am 2!'],
    :value_3 => ['3', 'Hey, I am 3!']
  )
end

class TestEnumerationWithoutArray < EnumerateIt::Base
  associate_values(
    :value_one => '1',
    :value_two => '2'
  )
end

class TestEnumerationWithExtendedBehaviour < EnumerateIt::Base
  associate_values(
    :first => '1',
    :second => '2'
  )
  def self.to_a
    super.reverse
  end
end

class TestEnumerationWithList < EnumerateIt::Base
  associate_values :first, :second
end

class Foobar < EnumerateIt::Base
  associate_values(
    :bar => 'foo'
  )
end

class BaseClass
  extend EnumerateIt
  has_enumeration_for :foobar, :with => TestEnumeration
end

def create_enumeration_class_with_sort_mode(sort_mode)
  Class.new(EnumerateIt::Base) do
    sort_by sort_mode

    associate_values(
      :foo  => ["1", "xyz"],
      :bar  => ["2", "fgh"],
      :zomg => ["3", "abc"]
    )
  end
end

