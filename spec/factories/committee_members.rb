# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :committee_member do
    committee # FactoryGirl
    user #FactoryGirl
    admin false
    voting true
  end
end
