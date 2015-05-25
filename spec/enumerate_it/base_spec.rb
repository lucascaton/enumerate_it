# encoding: utf-8
require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe EnumerateIt::Base do
  it "creates constants for each enumeration value" do
    [TestEnumeration::VALUE_1, TestEnumeration::VALUE_2, TestEnumeration::VALUE_3].each_with_index do |constant, idx|
      constant.should == (idx + 1).to_s
    end
  end

  it "creates constants for camel case values" do
    TestEnumerationWithCamelCase::IPHONE.should == 'iPhone'
  end

  it "creates constants replacing its dashes with underscores" do
    TestEnumerationWithDash::PT_BR.should == 'pt-BR'
  end

  it "creates a method that returns the allowed values in the enumeration's class" do
    TestEnumeration.list.should == ['1', '2', '3']
  end

  it "creates a method that returns the enumeration specification" do
    TestEnumeration.enumeration.should == {
      :value_1 => ['1', 'Hey, I am 1!'],
      :value_2 => ['2', 'Hey, I am 2!'],
      :value_3 => ['3', 'Hey, I am 3!']
    }
  end

  describe ".length" do
    it "returns the length of the enumeration" do
      TestEnumeration.length.should == 3
    end
  end

  describe ".each_translation" do
    it "yields each enumeration's value translation" do
      translations = []
      TestEnumeration.each_translation do |translation|
        translations << translation
      end
      translations.should == ["Hey, I am 1!", "Hey, I am 2!", "Hey, I am 3!"]
    end
  end

  describe ".translations" do
    it "returns all translations" do
      TestEnumeration.translations.should == ["Hey, I am 1!", "Hey, I am 2!", "Hey, I am 3!"]
    end
  end

  describe ".each_value" do
    it "yields each enumeration's value" do
      values = []
      TestEnumeration.each_value do |value|
        values << value
      end
      values.should == TestEnumeration.list
    end
  end

  describe ".to_a" do
    it "returns an array with the values and human representations" do
      TestEnumeration.to_a.should == [['Hey, I am 1!', '1'], ['Hey, I am 2!', '2'], ['Hey, I am 3!', '3']]
    end

    it "translates the available values" do
      TestEnumerationWithoutArray.to_a.should == [['First Value', '1'], ['Value Two', '2']]
      I18n.locale = :pt
      TestEnumerationWithoutArray.to_a.should == [['Primeiro Valor', '1'], ['Value Two', '2']]
    end

    it "can be extended from the enumeration class" do
      TestEnumerationWithExtendedBehaviour.to_a.should == [['Second', '2'],['First','1']]
    end
  end

  describe ".to_json" do
    it "gives a valid json back" do
      I18n.locale = :inexsistent
      TestEnumerationWithoutArray.to_json.should == '[{"value":"1","label":"Value One"},{"value":"2","label":"Value Two"}]'
    end

    it "give translated values when available" do
      I18n.locale = :pt
      TestEnumerationWithoutArray.to_json.should == '[{"value":"1","label":"Primeiro Valor"},{"value":"2","label":"Value Two"}]'
    end
  end

  describe ".t" do
    it "translates a given value" do
      I18n.locale = :pt
      TestEnumerationWithoutArray.t('1').should == 'Primeiro Valor'
    end
  end

  describe ".to_range" do
    it "returns a Range object containing the enumeration's value interval" do
      TestEnumeration.to_range.should == ("1".."3")
    end
  end

  describe ".values_for" do
    it "returns an array with the corresponding values for a string array representing some of the enumeration's values" do
      TestEnumeration.values_for(%w(VALUE_1 VALUE_2)).should == [TestEnumeration::VALUE_1, TestEnumeration::VALUE_2]
    end

    it "returns a nil value if the a constant named after one of the given strings cannot be found" do
      TestEnumeration.values_for(%w(VALUE_1 THIS_IS_WRONG)).should == [TestEnumeration::VALUE_1, nil]
    end
  end

  describe ".value_for" do
    it "returns the enumeration's value" do
      TestEnumeration.value_for("VALUE_1").should == TestEnumeration::VALUE_1
    end

    context "when a constant named after the received value cannot be found" do
      it "returns nil" do
        TestEnumeration.value_for("THIS_IS_WRONG").should be_nil
      end
    end
  end

  describe ".value_from_key" do
    it "returns the correct value when the key is a string" do
      TestEnumeration.value_from_key("value_1").should == TestEnumeration::VALUE_1
    end

    it "returns the correct value when the key is a symbol" do
      TestEnumeration.value_from_key(:value_1).should == TestEnumeration::VALUE_1
    end

    it "returns nil when the key does not exist in the enumeration" do
      TestEnumeration.value_from_key("wrong").should be_nil
    end

    it "returns nil when the given value is nil" do
      TestEnumeration.value_from_key(nil).should be_nil
    end
  end

  describe ".keys" do
    it "returns a list with the keys used to define the enumeration" do
      TestEnumeration.keys.should == [:value_1, :value_2, :value_3]
    end
  end

  describe ".key_for" do
    it "returns the key for the given value inside the enumeration" do
      TestEnumeration.key_for(TestEnumeration::VALUE_1).should == :value_1
    end

    it "returns nil if the enumeration does not have the given value" do
      TestEnumeration.key_for("foo").should be_nil
    end
  end

  context 'associate values with a list' do
    it "creates constants for each enumeration value" do
      TestEnumerationWithList::FIRST.should == "first"
      TestEnumerationWithList::SECOND.should == "second"
    end

    it "returns an array with the values and human representations" do
      TestEnumerationWithList.to_a.should == [['First', 'first'], ['Second', 'second']]
    end
  end

  context "specifying a default sort mode" do
    subject { create_enumeration_class_with_sort_mode(sort_mode).to_a }

    context "by value" do
      let(:sort_mode) { :value }

      it { should == [["jkl", "0"], ["xyz", "1"], ["fgh", "2"], ["abc", "3"]] }
    end

    context "by name" do
      let(:sort_mode) { :name }

      it { should == [["fgh", "2"], ["xyz", "1"], ["abc", "3"], ["jkl", "0"]] }
    end

    context "by translation" do
      let(:sort_mode) { :translation }

      it { should == [["abc", "3"] ,["fgh", "2"], ["jkl", "0"], ["xyz", "1"]] }
    end

    context "by nothing" do
      let(:sort_mode) { :none }

      it { should == [["xyz", "1"], ["fgh", "2"], ["abc", "3"], ["jkl", "0"] ] }
    end
  end

  context "when included in ActiveRecord::Base" do
    before :each do
      class ActiveRecordStub
        attr_accessor :bla

        class << self
          def validates_inclusion_of(options); true; end
          def validates_presence_of; true; end
        end
      end

      ActiveRecordStub.stub!(:validates_inclusion_of).and_return(true)
      ActiveRecordStub.extend EnumerateIt
    end

    it "creates a validation for inclusion" do
      ActiveRecordStub.should_receive(:validates_inclusion_of).with(:bla, :in => TestEnumeration.list, :allow_blank => true)
      class ActiveRecordStub
        has_enumeration_for :bla, :with => TestEnumeration
      end
    end

    context "using the :required option" do
      before :each do
        ActiveRecordStub.stub!(:validates_presence_of).and_return(true)
      end

      it "creates a validation for presence" do
        ActiveRecordStub.should_receive(:validates_presence_of)
        class ActiveRecordStub
          has_enumeration_for :bla, :with => TestEnumeration, :required => true
        end
      end

      it "passes the given options to the validation method" do
        ActiveRecordStub.should_receive(:validates_presence_of).with(:bla, :if => :some_method)
        class ActiveRecordStub
          has_enumeration_for :bla, :with => TestEnumeration, :required => { :if => :some_method }
        end
      end

      it "do not require the attribute by default" do
        ActiveRecordStub.should_not_receive(:validates_presence_of)
        class ActiveRecordStub
          has_enumeration_for :bla, :with => TestEnumeration
        end
      end
    end
  end
end
