require 'spec_helper'
describe 'adclient' do

  context 'with defaults for all parameters' do
    it { should contain_class('adclient') }
  end
end
