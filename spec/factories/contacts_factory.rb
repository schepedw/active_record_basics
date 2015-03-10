FactoryGirl.define do
  factory :contact do
    initialize_with { Contact.find_or_create_by(:email => 'test@test.com')}
  end
end
