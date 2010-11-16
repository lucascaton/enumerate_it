#encoding: utf-8
require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

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
