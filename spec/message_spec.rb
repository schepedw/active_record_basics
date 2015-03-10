require 'spec_helper'
describe Message do
  context 'required attributes' do

    it 'requires body' do
      expect(Message.new(:body => 'look at this body')).to be_valid
    end

    it 'errors without body' do
      expect(Message.new(:body => nil)).to_not be_valid
    end
  end

  context 'relations' do
    before do
      @message = FactoryGirl.create(:message)
      @attachment = FactoryGirl.create(:attachment, :message_recipients => @message.message_recipients)
      @shipment = FactoryGirl.create(:shipment, :messages => [@message])
    end

    it 'gets its recipients' do
      expect(@message.recipient_contacts.size).to eql 1
      expect(@message.recipient_contacts.first.email).to eql 'test@test.com'
    end

    it 'gets attachments' do
      expect(@message.attachments.size).to eql 1
      expect(@message.attachments.first).to eql @attachment
    end

    it 'gets shipments' do
      expect(@message.shipment).to eql @shipment
    end
  end
end
