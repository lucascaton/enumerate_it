#encoding: utf-8
require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

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
  include EnumerateIt
  has_enumeration_for :foobar, :with => TestEnumeration
end

describe EnumerateIt do
  before :each do
    class TestClass
      include EnumerateIt
      attr_accessor :foobar
      has_enumeration_for :foobar, :with => TestEnumeration

      def initialize(foobar); @foobar = foobar; end
      I18n.locale = :en
    end

    @target = TestClass.new(TestEnumeration::VALUE_2)
  end

  context "associating an enumeration with a class attribute" do
    it "creates an humanized description for the attribute's value" do
      @target.foobar_humanize.should == 'Hey, I am 2!'
    end

    it "if the attribute is blank, the humanize description is nil" do
      @target.foobar = nil
      @target.foobar_humanize.should be_nil
    end

    it "defaults to not creating helper methods" do
      @target.should_not respond_to(:value_1?)
    end

    it "stores the enumeration class in a class-level hash" do
      TestClass.enumerations[:foobar].should == TestEnumeration
    end

    context 'declaring a simple enum on an inherited class' do
      before do
        class SomeClass < BaseClass
          has_enumeration_for :foobar
        end
        @target = SomeClass.new
      end
      it 'should have use the corret class' do
        @base = BaseClass.new
        @base.class.enumerations[:foobar].should == TestEnumeration
        @target.class.enumerations[:foobar].should == Foobar
      end
    end

    context "passing the value of each option without the human string (just the value, without an array)" do
      before :each do
        class TestClassForEnumerationWithoutArray
          include EnumerateIt
          attr_accessor :foobar
          has_enumeration_for :foobar, :with => TestEnumerationWithoutArray

          def initialize(foobar); @foobar = foobar; end
        end

        @target = TestClassForEnumerationWithoutArray.new(TestEnumerationWithoutArray::VALUE_TWO)
      end

      it "humanizes the respective hash key" do
        @target.foobar_humanize.should == 'Value Two'
      end

      it "translates the respective hash key when a translation is found" do
        @target.foobar = TestEnumerationWithoutArray::VALUE_ONE
        @target.foobar_humanize.should == 'First Value'
        I18n.locale = :pt

        @target.foobar_humanize.should == 'Primeiro Valor'
      end
    end

    context "without passing the enumeration class" do
      before :each do
        class FooBar
          include EnumerateIt
          attr_accessor :test_enumeration
          has_enumeration_for :test_enumeration
          def initialize(test_enumeration_value)
            @test_enumeration = test_enumeration_value
          end
        end
      end

      it "should find out which enumeration class to use" do
        target = FooBar.new(TestEnumeration::VALUE_1)
        target.test_enumeration_humanize.should == 'Hey, I am 1!'
      end
    end
  end

  context "using the :create_helpers option" do
    before :each do
      class TestClass
        has_enumeration_for :foobar, :with => TestEnumeration, :create_helpers => true
      end
    end

    it "creates helpers methods with question marks for each enumeration option" do
      target = TestClass.new(TestEnumeration::VALUE_2)
      target.should be_value_2
      target.should_not be_value_1
    end

    it "creates a mutator method for each enumeration value" do
      [:value_1, :value_2, :value_3].each do |value|
        TestClass.new(TestEnumeration::VALUE_1).should respond_to(:"#{value}!")
      end
    end

    it "changes the attribute's value through mutator methods" do
      target = TestClass.new(TestEnumeration::VALUE_2)
      target.value_3!
      target.foobar.should == TestEnumeration::VALUE_3
    end
  end

  describe "using the :create_scopes option" do
    def setup_enumeration
      TestClass.send(:has_enumeration_for, :foobar, :with => TestEnumeration, :create_scopes => true)
    end

    context "if the hosting class responds to :scope" do
      before do
        class TestClass
          def self.where(whatever); end
          def self.scope(name, whatever); end
        end

        setup_enumeration
      end

      it "creates a scope for each enumeration value" do
        TestEnumeration.enumeration do |symbol, pair|
          TestClass.should respond_to(symbol)
        end
      end

      it "when called, the scopes create the correct query" do
        TestEnumeration.enumeration do |symbol, pair|
          TestClass.should_receive(:where).with(:foobar => pair.firs)
          TestClass.send symbol
        end
      end
    end

    context "when the hosting class do not respond to :scope" do
      it "raises no errors" do
        expect {
          setup_enumeration
        }.to_not raise_error
      end
    end
  end
end

describe EnumerateIt::Base do
  it "creates constants for each enumeration value" do
    [TestEnumeration::VALUE_1, TestEnumeration::VALUE_2, TestEnumeration::VALUE_3].each_with_index do |constant, idx|
      constant.should == (idx + 1).to_s
    end
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

  describe "#to_range" do
    it "returns a Range object containing the enumeration's value interval" do
      TestEnumeration.to_range.should == ("1".."3")
    end
  end

  describe ".values_for" do
    it "returns an array with the corresponding values for a string array representing some of the enumeration's values" do
      TestEnumeration.values_for(%w(VALUE_1 VALUE_2)).should == [TestEnumeration::VALUE_1, TestEnumeration::VALUE_2]
    end
  end

  describe "#value_for" do
    it "returns the enumeration's value" do
      TestEnumeration.value_for("VALUE_1").should == TestEnumeration::VALUE_1
    end
  end

  describe "#key_for" do
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
      ActiveRecordStub.send :include, EnumerateIt
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
