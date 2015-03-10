require 'spec_helper'
describe Attachment do
  context 'required attributes' do 
    it 'accepts the required attributes' do
      expect{
        FactoryGirl.create(:attachment)
      }.to change(Attachment, :count).by(1)
    end

    it 'is invalid without filename' do
      a = Attachment.create(:content => 'hello', :file_type => 'pdf', :filename => nil)
      expect(a).to_not be_valid
    end

    it 'is invalid without file type' do
      a = Attachment.create(:content => 'hello', :file_type => nil, :filename => 'abcd')
      expect(a).to_not be_valid
    end

    it 'is invalid without content' do
      a = Attachment.create(:content => nil, :file_type => 'pdf', :filename => 'abcd')
      expect(a).to_not be_valid
    end
  end

  context 'relations' do
    before do
      @message = FactoryGirl.create(:message)
      @attachment = FactoryGirl.create(:attachment, :message_recipients => @message.message_recipients)
    end

    it 'can get the message it belongs to' do
      expect(@attachment.messages.size).to eql 1
      expect(@attachment.messages.first).to eql @message
    end

    it 'can get its recipients' do
      expect(@attachment.recipient_contacts.size).to eql 1
      expect(@attachment.recipient_contacts.first.email).to eql 'test@test.com'
    end

    context 'nested' do
      it 'cannot set recipient_contacts' do
        expect{@attachment.recipient_contacts = [FactoryGirl.create(:contact)]}.to raise_error(ActiveRecord::HasManyThroughNestedAssociationsAreReadonly)
      end
    end
  end

end
