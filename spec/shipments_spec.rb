require 'spec_helper'

describe Shipment do
  context 'required attributse' do
    before do 
      Shipment.delete_all
    end

    it 'saves with correct attributes' do
      expect{
        FactoryGirl.create(:shipment)
      }.to change(Shipment, :count).by(1)
    end

    it 'is invalid without required attributes' do
      shipment = FactoryGirl.build(:shipment, :from => nil)
      expect(shipment).to_not be_valid
    end

  end

  context 'relations' do
    before do
      @message = FactoryGirl.create(:message)
      @attachment = FactoryGirl.create(:attachment, :message_recipients => @message.message_recipients)
      @shipment = FactoryGirl.create(:shipment, :messages => [@message])
    end

    it 'gets messages' do
      expect(@shipment.messages.size).to eql 1
      expect(@shipment.messages.first).to eql @message
    end

    it 'gets attachments' do
      expect(@shipment.attachments.size).to eql 1
      expect(@shipment.attachments.first).to eql @attachment
    end

    it 'gets recipients' do
      expect(@shipment.recipient_contacts.size).to eql 1
      expect(@shipment.recipient_contacts.first.email).to eql 'test@test.com'
    end

    context 'setting nested relations' do
      it 'cannot set attachments' do
        expect{@shipment.attachments = [FactoryGirl.create(:attachment)]}.to raise_error(ActiveRecord::HasManyThroughNestedAssociationsAreReadonly)
      end

      it 'cannot set recipient_contacts' do
        expect{@shipment.recipient_contacts = [FactoryGirl.create(:contact)]}.to raise_error(ActiveRecord::HasManyThroughNestedAssociationsAreReadonly)
      end
    end

  end
end
