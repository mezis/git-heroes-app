require 'rails_helper'

describe 'Factories' do
  FactoryGirl.factories.each do |f|
    it "creates #{f.name}" do
      FactoryGirl.lint [f], traits: true
    end
  end
end
