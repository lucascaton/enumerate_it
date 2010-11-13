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
    end

    describe ".values_for" do
      it "returns an array with the corresponding values for a string array representing some of the enumeration's values" do
        TestEnumeration.values_for(%w(VALUE_1 VALUE_2)).should == [TestEnumeration::VALUE_1, TestEnumeration::VALUE_2]
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

        it "do not require the attribute by default" do
          ActiveRecordStub.should_not_receive(:validates_presence_of)
          class ActiveRecordStub
            has_enumeration_for :bla, :with => TestEnumeration
          end
        end
      end
    end
  end
end
