#encoding: utf-8
require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

class TestEnumeration < EnumerateIt::Base
  associate_values(
    :value_1 => ['1', 'Hey, I am 1!'],
    :value_2 => ['2', 'Hey, I am 2!'],
    :value_3 => ['3', 'Hey, I am 3!']
  )
end

describe EnumerateIt do
  before :each do
    class TestClass
      include EnumerateIt
      attr_accessor :foobar
      has_enumeration_for :foobar, :with => TestEnumeration

      def initialize(foobar)
        @foobar = foobar
      end
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
  end

  context "using the option :create_helpers option" do
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
    end

    context "when included in ActiveRecord::Base" do
      before :each do
        class ActiveRecordStub; attr_accessor :bla; end
        ActiveRecordStub.stub!(:respond_to?).with(:validates_inclusion_of).and_return(true)
        ActiveRecordStub.stub!(:validates_inclusion_of).and_return(true)
        ActiveRecordStub.send :include, EnumerateIt
      end

      it "creates a validation for inclusion" do
        ActiveRecordStub.should_receive(:validates_inclusion_of).with(:bla, :in => TestEnumeration.list, :allow_blank => true)
        class ActiveRecordStub
          has_enumeration_for :bla, :with => TestEnumeration
        end
      end
    end
  end
end
