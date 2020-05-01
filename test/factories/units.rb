FactoryBot.define do
  factory :unit do
    gang { nil }
    libe { 'seigneur' }
    amount { 1 }
    points { 0 }
    weapon { '-' }
    name { 'Default lord name' }

    factory :unit_lord_horde do
      libe { 'seigneur' }
      name { 'Zak' }
    end

    factory :unit_sorcerer_horde do
      libe { 'sorcier' }
      name { 'Yssik' }
      points { 1 }
    end

    factory :unit_gardes_horde do
      libe { 'gardes' }
      name { 'Wyvorn' }
      points { 1 }
      amount { 4 }
    end

    factory :unit_levees_horde do
      libe { 'levees' }
      name { 'Wraythe' }
      weapon { 'arc_ou_fronde' }
      points { 1 }
      amount { 12 }
    end

    factory :unit_lord_nature do
      libe { 'seigneur' }
      name { 'William' }
    end

    factory :unit_sorcerer_nature do
      libe { 'sorcier' }
      name { 'Witfar' }
      points { 1 }
    end

    factory :unit_gardes_nature do
      libe { 'gardes' }
      name { 'Werymn' }
      weapon { 'arc' }
      points { 1 }
      amount { 4 }
    end

    factory :unit_guerriers_nature do
      libe { 'guerriers' }
      name { 'Volux' }
      points { 1 }
      amount { 8 }
    end

  end
end
