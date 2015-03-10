FactoryGirl.define do
  factory :message do
    body 'look at this body'
    recipient_contacts  [FactoryGirl.create(:contact)]
  end
end
