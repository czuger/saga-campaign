FactoryBot.define do
  factory :unit do
    gang { nil }
    libe { 'seigneur' }
    amount { 1 }
    points { 1.5 }
    weapon { '-' }
    name { 'Default lord name' }

    factory :unit_lord_horde do
      libe { 'seigneur' }
      name { 'Zak' }
    end

    factory :unit_sorcerer_horde do
      libe { 'sorcier' }
      name { 'Yssik' }
    end

    factory :unit_gardes_horde do
      libe { 'gardes' }
      name { 'Wyvorn' }
    end

    factory :unit_levees_horde do
      libe { 'levees' }
      name { 'Wraythe' }
      weapon { 'arc_ou_fronde' }
    end

    factory :unit_lord_nature do
      libe { 'seigneur' }
      name { 'William' }
    end

    factory :unit_sorcerer_nature do
      libe { 'sorcier' }
      name { 'Witfar' }
    end

    factory :unit_gardes_nature do
      libe { 'gardes' }
      name { 'Werymn' }
      weapon { 'arc' }
    end

    factory :unit_guerriers_nature do
      libe { 'guerriers' }
      name { 'Volux' }
    end

  end
end
