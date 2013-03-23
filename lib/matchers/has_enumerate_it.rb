# encoding: utf-8

# EnumerateIt matchers
#  class Job < EnumerateIt::Base
#   associate_values one: 'um'
# end

# class Enumerations
#   extend EnumerateIt
#   has_enumeration_for :job
#   has_enumeration_for :last, with: Job
# end

# it { should has_enumeration_for :job }
# it { should has_enumeration_for :last, Job }

# should has enumeration for job
# should has enumeration for last with Job

module EnumerateIt
  module Matchers

    def has_enumeration_for expected, klass=nil
      HasEnumerationForMatcher.new expected, klass
    end

    class HasEnumerationForMatcher

      def initialize expected, klass=nil
        @expected = expected
        @klass = klass
      end

      def matches? subject
        @subject = subject
        @subject.class.enumerations.any? { |k,v| k.eql?(@expected) && v.eql?(enumerate_name) }
      end

      def failure_message
        "has enumeration for '#{@expected}' with '#{enumerate_name}'"
      end

      def description
        "'#{@expected}' has enumeration for '#{enumerate_name}'"
      end

      private
      def enumerate_name
        @klass ||= @expected.to_s.classify.constantize
      end
    end
  end
end
