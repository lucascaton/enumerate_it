# encoding: utf-8
require 'spec_helper'

describe 'HasEnumerationFor::Matchers' do
  class Job < EnumerateIt::Base
    associate_values one: 1
  end

  class EnumerationsClient
    extend EnumerateIt
    has_enumeration_for :job
    has_enumeration_for :last, with: Job
  end

  subject { EnumerationsClient.new }

  it { should has_enumeration_for :job }
  it { should has_enumeration_for :last, Job }
  it { should_not has_enumeration_for :next, Job }
end
