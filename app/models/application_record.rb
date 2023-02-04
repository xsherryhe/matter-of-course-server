class ApplicationRecord < ActiveRecord::Base
  primary_abstract_class

  def simplified_errors
    errors.each_with_object({}) do |error, hash|
      (hash[error.attribute] ||= []) << error.message
    end
  end

  private

  def add_unique(association, records)
    records.each do |record|
      next unless record

      association << record unless association.exists?(record.id) || association.include?(record)
    end
  end
end
