require 'spec_helper'
require 'couchsurfing'

describe CouchSurfing do
  let(:cs_instance) { CouchSurfing.instance }

  context 'valid config' do
    before do
      CouchSurfing
        .stub(:credentials) { {'username' => 'user', 'password' => 'pass'} }
    end


    it 'passes username and password to new CouchSurfingClient instance' do
      CouchSurfingClient::CouchSurfing.any_instance.stub(:sign_in)

      expect(cs_instance.username).to eq 'user'
      expect(cs_instance.password).to eq 'pass'
    end

    it 'signs in' do
      CouchSurfingClient::CouchSurfing.any_instance
        .should_receive(:sign_in)

    cs_instance
    end
  end

  context 'invalid config' do
    it 'raises exception if password is not defined' do
      CouchSurfing.stub(:fetch_config) { {'username' => 'user'} }

      expect { CouchSurfing.instance }.to raise_error
    end
  end
end
