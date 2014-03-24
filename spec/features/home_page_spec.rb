require 'spec_helper'

describe 'Sign in process' do
  it 'has sign in link' do
    visit '/'
    expect(has_link?('Login')).to be_true
  end

  it 'is able to sign up' do
    visit '/'
    click 'Login'

  end
end
