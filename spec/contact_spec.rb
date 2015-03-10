require 'spec_helper'
describe Contact do 
  context 'required attributes' do
    before do
      Contact.delete_all
    end
    it 'accepts correct attributes' do
      expect{
        Contact.create(:email => 'test@example.com')
      }.to change(Contact, :count).by(1)
    end

    it 'forces uniqueness' do
      Contact.create(:email => 'test@example.com')
      expect{
        Contact.create(:email => 'test@example.com')
      }.to change(Contact, :count).by(0)
    end
  end
end
