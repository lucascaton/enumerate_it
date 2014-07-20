#encoding: utf-8
require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe EnumerateIt do
  before :each do
    class TestClass
      extend EnumerateIt
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

    context 'use the same enumeration from an inherited class' do
      before do
        class SomeClass < BaseClass
        end
        @target = SomeClass.new
      end

      it 'should have use the correct class' do
        @base = BaseClass.new
        @base.class.enumerations[:foobar].should == TestEnumeration
        @target.class.enumerations[:foobar].should == TestEnumeration
      end
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
          extend EnumerateIt
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
          extend EnumerateIt
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

      context "when using a nested class as the enumeration" do
        before do
          class NestedEnum < EnumerateIt::Base
            associate_values :foo => ['1', 'Fooo'], :bar => ['2', 'Barrrr']
          end

          class ClassWithNestedEnum
            class NestedEnum < EnumerateIt::Base
              associate_values :foo => ['1', 'Blerrgh'], :bar => ['2' => 'Blarghhh']
            end

            extend EnumerateIt

            attr_accessor :nested_enum

            has_enumeration_for :nested_enum

            def initialize(nested_enum_value)
              @nested_enum = nested_enum_value
            end
          end
        end

        it "uses the inner class as the enumeration class" do
          target = ClassWithNestedEnum.new('1').nested_enum_humanize.should == 'Blerrgh'
        end
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

    context "with :prefix option" do
      before :each do
        class TestClass
          has_enumeration_for :foobar, :with => TestEnumeration, :create_helpers => { :prefix => true }
        end
      end

      it "creates helpers methods with question marks and prefixes for each enumeration option" do
        target = TestClass.new(TestEnumeration::VALUE_2)
        target.should be_foobar_value_2
      end

      it "creates a mutator method for each enumeration value" do
        [:value_1, :value_2, :value_3].each do |value|
          TestClass.new(TestEnumeration::VALUE_1).should respond_to(:"foobar_#{value}!")
        end
      end

      it "changes the attribute's value through mutator methods" do
        target = TestClass.new(TestEnumeration::VALUE_2)
        target.foobar_value_3!
        target.foobar.should == TestEnumeration::VALUE_3
      end
    end

    context "with :polymorphic option" do
      before :each do
        class Polymorphic
          extend EnumerateIt
          attr_accessor :foo
          has_enumeration_for :foo, :with => PolymorphicEnum, :create_helpers => { :polymorphic => true }
        end
      end

      it "calls methods on the enum constants' objects" do
        target = Polymorphic.new
        target.foo = PolymorphicEnum::NORMAL

        target.foo_object.print("Gol").should == "I'm Normal: Gol"

        target.foo = PolymorphicEnum::CRAZY

        target.foo_object.print("Gol").should == "Whoa!: Gol"
      end

      it "returns nil if foo is not set" do
        target = Polymorphic.new

        target.foo_object.should be_nil
      end

      context "and :suffix" do
        before :each do
          class Polymorphic
            has_enumeration_for :foo, :with => PolymorphicEnum, :create_helpers => { :polymorphic => { :suffix => "_strategy" } }
          end
        end

        it "calls methods on the enum constants' objects" do
          target = Polymorphic.new
          target.foo = PolymorphicEnum::NORMAL

          target.foo_strategy.print("Gol").should == "I'm Normal: Gol"

          target.foo = PolymorphicEnum::CRAZY

          target.foo_strategy.print("Gol").should == "Whoa!: Gol"
        end
      end
    end
  end

  describe "using the :create_scopes option" do
    def setup_enumeration
      OtherTestClass.send(:has_enumeration_for, :foobar, :with => TestEnumeration, :create_scopes => true)
    end

    context "if the hosting class responds to :scope" do
      before do
        class OtherTestClass < ActiveRecord::Base
          extend EnumerateIt
        end

        setup_enumeration
      end

      it "creates a scope for each enumeration value" do
        TestEnumeration.enumeration.keys.each do |symbol|
          OtherTestClass.should respond_to(symbol)
        end
      end

      it "when called, the scopes create the correct query" do
        TestEnumeration.enumeration.each do |symbol, pair|
          OtherTestClass.should_receive(:where).with(:foobar => pair.first)
          OtherTestClass.send symbol
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

    context "with :prefix option" do
      before do
        class OtherTestClass
          extend EnumerateIt
          has_enumeration_for :foobar, :with => TestEnumerationWithReservedWords, :create_scopes => { :prefix => true }
        end
      end

      it "creates a scope with prefix for each enumeration value" do
        TestEnumerationWithReservedWords.enumeration.keys.each do |symbol|
          OtherTestClass.should respond_to(:"foobar_#{symbol}")
        end
      end
    end
  end
end

