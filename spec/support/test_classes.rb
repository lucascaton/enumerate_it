class TestEnumeration < EnumerateIt::Base
  associate_values(
    value_1: ['1', 'Hey, I am 1!'],
    value_2: ['2', 'Hey, I am 2!'],
    value_3: ['3', 'Hey, I am 3!']
  )
end

class TestEnumerationWithoutArray < EnumerateIt::Base
  associate_values value_one: '1', value_two: '2'
end

class TestEnumerationWithExtendedBehaviour < EnumerateIt::Base
  associate_values first: '1', second: '2'

  def self.to_a
    super.reverse
  end
end

class TestEnumerationWithList < EnumerateIt::Base
  associate_values :first, :second
end

class TestEnumerationWithReservedWords < EnumerateIt::Base
  associate_values new: 1, no_schedule: 2, with_schedule: 3, suspended: 4
end

class TestEnumerationWithDash < EnumerateIt::Base
  associate_values 'pt-BR'
end

class TestEnumerationWithCamelCase < EnumerateIt::Base
  associate_values 'iPhone'
end

class TestEnumerationWithSpaces < EnumerateIt::Base
  associate_values 'spa ces'
end

class Foobar < EnumerateIt::Base
  associate_values bar: 'foo'
end

class PolymorphicEnum < EnumerateIt::Base
  associate_values :normal, :crazy

  class Normal
    def print(msg)
      "I'm Normal: #{msg}"
    end
  end

  class Crazy
    def print(msg)
      "Whoa!: #{msg}"
    end
  end
end

class BaseClass
  extend EnumerateIt

  has_enumeration_for :foobar, with: TestEnumeration
end

def create_enumeration_class_with_sort_mode(sort_mode)
  Class.new(EnumerateIt::Base) do
    sort_by(sort_mode)

    associate_values(
      foo:  %w[1 xyz],
      bar:  %w[2 fgh],
      omg:  %w[3 abc],
      zomg: %w[0 jkl]
    )
  end
end
