module OrderedAssociations
  extend ActiveSupport::Concern

  DEFAULTS = { by: :position }

  def update_ordering(association, field)
    # put the new objects last
    old, fresh = send(association).partition(&:"#{field}?")
    old.sort_by!(&field)
    old.concat(fresh).each_with_index do |record, i|
      record.send :"#{field}=", i
    end
  end

  module ClassMethods
    def keep_ordered(*associations)
      options = associations.extract_options!.reverse_merge self::DEFAULTS

      associations.each do |association|
        class_eval <<EORUBY, __FILE__, __LINE__ + 1
          def update_ordering_for_#{association}
            update_ordering :#{association}, :#{options[:by]}
          end

          before_validation :update_ordering_for_#{association}
EORUBY
      end
    end
  end
end
