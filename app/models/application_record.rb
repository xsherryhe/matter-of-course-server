class ApplicationRecord < ActiveRecord::Base
  primary_abstract_class

  def simplified_errors(options = {})
    simple_errors = errors.each_with_object({}) do |error, hash|
      attribute = error.attribute[0..(/_id$/ =~ error.attribute ? -4 : -1)]
      (hash[attribute] ||= []) << error.message
    end

    add_association_errors(simple_errors, options[:include])
    simple_errors
  end

  private

  def add_unique(association, records)
    records.each do |record|
      next unless record

      association << record unless association.exists?(record.id) || association.include?(record)
    end
  end

  def add_association_errors(errors, included_associations)
    included_associations&.each do |association|
      errors["#{association}_errors"] = [public_send(association)].flatten(1).each_with_object({}) do |instance, hash|
        hash[instance.id] = instance.simplified_errors
      end
    end
  end
end
