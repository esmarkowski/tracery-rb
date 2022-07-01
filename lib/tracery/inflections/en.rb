ActiveSupport::Inflector.inflections(:en) do |inflect|
    inflect.plural /^(ox)$/i, '\1\2en'
    inflect.singular /^(ox)en/i, '\1'
  
    inflect.irregular 'cactus', 'cacti'

    inflect.uncountable 'broccoli'
    inflect.uncountable 'celery'
    inflect.uncountable 'deer'
    inflect.uncountable 'elk'
    inflect.uncountable 'moose'
  
    inflect.uncountable 'equipment'
end