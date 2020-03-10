require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe EnumerateIt::Base do
  it 'creates constants for each enumeration value' do
    constants = [TestEnumeration::VALUE_1, TestEnumeration::VALUE_2, TestEnumeration::VALUE_3]

    constants.each_with_index do |constant, idx|
      expect(constant).to eq((idx + 1).to_s)
    end
  end

  it 'creates constants for camel case values' do
    expect(TestEnumerationWithCamelCase::IPHONE).to eq('iPhone')
  end

  it 'creates constants replacing its dashes with underscores' do
    expect(TestEnumerationWithDash::PT_BR).to eq('pt-BR')
  end

  it 'creates constants for values with spaces' do
    expect(TestEnumerationWithSpaces::SPA_CES).to eq('spa ces')
  end

  describe '.list' do
    it "creates a method that returns the allowed values in the enumeration's class" do
      expect(TestEnumeration.list).to eq(%w[1 2 3])
    end

    context 'specifying a default sort mode' do
      subject { create_enumeration_class_with_sort_mode(sort_mode).list }

      context 'by value' do
        let(:sort_mode) { :value }

        it { is_expected.to eq(%w[0 1 2 3]) }
      end

      context 'by name' do
        let(:sort_mode) { :name }

        it { is_expected.to eq(%w[2 1 3 0]) }
      end

      context 'by translation' do
        let(:sort_mode) { :translation }

        it { is_expected.to eq(%w[3 2 0 1]) }
      end

      context 'by nothing' do
        let(:sort_mode) { :none }

        it { is_expected.to eq(%w[1 2 3 0]) }
      end
    end
  end

  it 'creates a method that returns the enumeration specification' do
    expect(TestEnumeration.enumeration).to eq(
      value_1: ['1', 'Hey, I am 1!'],
      value_2: ['2', 'Hey, I am 2!'],
      value_3: ['3', 'Hey, I am 3!']
    )
  end

  describe '.length' do
    it 'returns the length of the enumeration' do
      expect(TestEnumeration.length).to eq(3)
    end
  end

  describe '.each_translation' do
    it "yields each enumeration's value translation" do
      translations = []
      TestEnumeration.each_translation do |translation|
        translations << translation
      end
      expect(translations).to eq(['Hey, I am 1!', 'Hey, I am 2!', 'Hey, I am 3!'])
    end
  end

  describe '.translations' do
    it 'returns all translations' do
      expect(TestEnumeration.translations).to eq(['Hey, I am 1!', 'Hey, I am 2!', 'Hey, I am 3!'])
    end
  end

  describe '.each_key' do
    it "yields each enumeration's key" do
      keys = []
      TestEnumeration.each_key do |key|
        keys << key
      end
      expect(keys).to eq(%i[value_1 value_2 value_3])
    end
  end

  describe '.each_value' do
    it "yields each enumeration's value" do
      values = []
      TestEnumeration.each_value do |value|
        values << value
      end
      expect(values).to eq(TestEnumeration.list)
    end
  end

  describe '.to_a' do
    it 'returns an array with the values and human representations' do
      expect(TestEnumeration.to_a)
        .to eq([['Hey, I am 1!', '1'], ['Hey, I am 2!', '2'], ['Hey, I am 3!', '3']])
    end

    it 'translates the available values' do
      I18n.locale = :en
      expect(TestEnumerationWithoutArray.to_a).to eq([['First Value', '1'], ['Value Two', '2']])
      I18n.locale = :pt
      expect(TestEnumerationWithoutArray.to_a).to eq([['Primeiro Valor', '1'], ['Value Two', '2']])
    end

    it 'can be extended from the enumeration class' do
      expect(TestEnumerationWithExtendedBehaviour.to_a).to eq([%w[Second 2], %w[First 1]])
    end
  end

  describe '.to_h' do
    it 'returns a hash' do
      expect(TestEnumerationWithoutArray.to_h).to eq(value_one: '1', value_two: '2')
    end
  end

  describe '.to_json' do
    it 'gives a valid json back' do
      I18n.locale = :inexsistent
      expect(TestEnumerationWithoutArray.to_json)
        .to eq('[{"value":"1","label":"Value One"},{"value":"2","label":"Value Two"}]')
    end

    it 'give translated values when available' do
      I18n.locale = :pt
      expect(TestEnumerationWithoutArray.to_json)
        .to eq('[{"value":"1","label":"Primeiro Valor"},{"value":"2","label":"Value Two"}]')
    end
  end

  describe '.t' do
    it 'translates a given value' do
      I18n.locale = :pt
      expect(TestEnumerationWithoutArray.t('1')).to eq('Primeiro Valor')
    end
  end

  describe '.to_range' do
    it "returns a Range object containing the enumeration's value interval" do
      expect(TestEnumeration.to_range).to eq('1'..'3')
    end
  end

  describe '.values_for' do
    it "returns an array representing some of the enumeration's values" do
      expect(TestEnumeration.values_for(%w[VALUE_1 VALUE_2]))
        .to eq([TestEnumeration::VALUE_1, TestEnumeration::VALUE_2])
    end

    it 'returns nil if the a constant named after one of the given strings cannot be found' do
      expect(TestEnumeration.values_for(%w[VALUE_1 THIS_IS_WRONG]))
        .to eq([TestEnumeration::VALUE_1, nil])
    end
  end

  describe '.value_for' do
    it "returns the enumeration's value" do
      expect(TestEnumeration.value_for('VALUE_1')).to eq(TestEnumeration::VALUE_1)
    end

    context 'when a constant named after the received value cannot be found' do
      it 'returns nil' do
        expect(TestEnumeration.value_for('THIS_IS_WRONG')).to be_nil
      end
    end
  end

  describe '.value_from_key' do
    it 'returns the correct value when the key is a string' do
      expect(TestEnumeration.value_from_key('value_1')).to eq(TestEnumeration::VALUE_1)
    end

    it 'returns the correct value when the key is a symbol' do
      expect(TestEnumeration.value_from_key(:value_1)).to eq(TestEnumeration::VALUE_1)
    end

    it 'returns nil when the key does not exist in the enumeration' do
      expect(TestEnumeration.value_from_key('wrong')).to be_nil
    end

    it 'returns nil when the given value is nil' do
      expect(TestEnumeration.value_from_key(nil)).to be_nil
    end
  end

  describe '.keys' do
    it 'returns a list with the keys used to define the enumeration' do
      expect(TestEnumeration.keys).to eq(%i[value_1 value_2 value_3])
    end
  end

  describe '.key_for' do
    it 'returns the key for the given value inside the enumeration' do
      expect(TestEnumeration.key_for(TestEnumeration::VALUE_1)).to eq(:value_1)
    end

    it 'returns nil if the enumeration does not have the given value' do
      expect(TestEnumeration.key_for('foo')).to be_nil
    end
  end

  context 'associate values with a list' do
    it 'creates constants for each enumeration value' do
      expect(TestEnumerationWithList::FIRST).to  eq('first')
      expect(TestEnumerationWithList::SECOND).to eq('second')
    end

    it 'returns an array with the values and human representations' do
      expect(TestEnumerationWithList.to_a).to eq([%w[First first], %w[Second second]])
    end
  end

  context 'not specifying a sort mode' do
    subject(:enumeration) { create_enumeration_class_with_sort_mode(nil) }

    it 'does not sort' do
      expect(enumeration.to_a).to eq([%w[xyz 1], %w[fgh 2], %w[abc 3], %w[jkl 0]])
    end
  end

  context 'specifying a sort mode' do
    subject(:enumeration) { create_enumeration_class_with_sort_mode(sort_mode) }

    context 'by value' do
      let(:sort_mode) { :value }

      it { expect(enumeration.to_a).to eq([%w[jkl 0], %w[xyz 1], %w[fgh 2], %w[abc 3]]) }
    end

    context 'by name' do
      let(:sort_mode) { :name }

      it { expect(enumeration.to_a).to eq([%w[fgh 2], %w[xyz 1], %w[abc 3], %w[jkl 0]]) }
    end

    context 'by translation' do
      let(:sort_mode) { :translation }

      it { expect(enumeration.to_a).to eq([%w[abc 3], %w[fgh 2], %w[jkl 0], %w[xyz 1]]) }
    end

    context 'by nothing' do
      let(:sort_mode) { :none }

      it { expect(enumeration.to_a).to eq([%w[xyz 1], %w[fgh 2], %w[abc 3], %w[jkl 0]]) }
    end
  end

  context 'when included in ActiveRecord::Base' do
    let(:active_record_stub_class) do
      Class.new do
        extend EnumerateIt

        attr_accessor :bla

        class << self
          def validates_inclusion_of(_attribute, _options)
            true
          end

          def validates_presence_of
            true
          end
        end
      end
    end

    it 'creates a validation for inclusion' do
      expect(active_record_stub_class)
        .to receive(:validates_inclusion_of).with(:bla, in: TestEnumeration.list, allow_blank: true)

      active_record_stub_class.class_eval do
        has_enumeration_for :bla, with: TestEnumeration
      end
    end

    context 'using the :required option' do
      before do
        allow(active_record_stub_class).to receive(:validates_presence_of).and_return(true)
      end

      it 'creates a validation for presence' do
        expect(active_record_stub_class).to receive(:validates_presence_of)
        active_record_stub_class.class_eval do
          has_enumeration_for :bla, with: TestEnumeration, required: true
        end
      end

      it 'passes the given options to the validation method' do
        expect(active_record_stub_class)
          .to receive(:validates_presence_of).with(:bla, if: :some_method)

        active_record_stub_class.class_eval do
          has_enumeration_for :bla, with: TestEnumeration, required: { if: :some_method }
        end
      end

      it 'does not require the attribute by default' do
        expect(active_record_stub_class).not_to receive(:validates_presence_of)
        active_record_stub_class.class_eval do
          has_enumeration_for :bla, with: TestEnumeration
        end
      end
    end

    context 'using :skip_validation option' do
      it "doesn't create a validation for inclusion" do
        expect(active_record_stub_class).not_to receive(:validates_inclusion_of)
        active_record_stub_class.class_eval do
          has_enumeration_for :bla, with: TestEnumeration, skip_validation: true
        end
      end

      it "doesn't create a validation for presence" do
        expect(active_record_stub_class).not_to receive(:validates_presence_of)
        active_record_stub_class.class_eval do
          has_enumeration_for :bla, with: TestEnumeration, require: true, skip_validation: true
        end
      end
    end
  end
end
