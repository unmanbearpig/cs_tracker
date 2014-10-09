require 'spec_helper'

describe 'Sign in process', type: :feature do
  it 'has sign in link' do
    visit '/'
    expect(has_link?('Sign in')).to be true
  end

  it 'is able to sign up' do
    visit '/'
    click_link 'Sign in'
    click_link 'Sign up'
    fill_in 'Email', with: Faker::Internet.email
    password = SecureRandom.hex(10)
    fill_in 'Password', with: password
    fill_in 'Password confirmation', with: password
    click_button 'Sign up'

    expect(has_link?('Sign out')).to be true
  end
end
