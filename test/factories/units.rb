FactoryBot.define do
  factory :unit do
    gang { nil }
    libe { "MyString" }
    amount { 1 }
    points { 1.5 }
    weapon { '-' }
  end
end
