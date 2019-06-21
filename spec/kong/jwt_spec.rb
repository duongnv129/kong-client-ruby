require_relative "../spec_helper"
require 'pry-byebug'

describe Kong::JWT do
  let(:valid_attribute_names) do
    %w(id key secret consumer_id)
  end

  describe 'ATTRIBUTE_NAMES' do
    it 'contains valid names' do
      expect(subject.class::ATTRIBUTE_NAMES).to eq(valid_attribute_names)
    end
  end

  describe 'API_END_POINT' do
    it 'contains valid end point' do
      expect(subject.class::API_END_POINT).to eq('/jwt/')
    end
  end

  describe '#init_attributes' do
    it 'uses correct api end point if consumer_id is present' do
      subject = described_class.new({ consumer_id: ':consumer_id' })
      expect(subject.api_end_point).to eq('/consumers/:consumer_id/jwt/')
    end
  end

  describe '#create' do
    context 'using Kong ^1.0 schema reject consumer_id' do
      it 'should not send consumer_id in request_payload' do
        headers = { 'Content-Type' => 'application/json' }
        attributes = { 'consumer_id' => ':consumer_id', 'key' => ':key', 'secret' =>  ':secret' }
        except_consumer_hash =  { 'key' => ':key', 'secret' =>  ':secret' }

        expect(Kong::Client.instance)
          .to receive(:post).with('/consumers/:consumer_id/jwt/', except_consumer_hash, nil, headers)
                .and_return(attributes)

        subject = described_class.new(attributes)
        subject.create
      end
    end
  end
end
