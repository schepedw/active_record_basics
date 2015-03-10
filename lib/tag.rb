# == Schema Information
#
# Table name: tags
#
#  id    :integer          not null, primary key
#  value :string(255)      not null, indexed
#
# Indexes
#
#  index_tags_on_value  (value) UNIQUE
#

class Tag < ActiveRecord::Base
  has_and_belongs_to_many :messages

  lookup_by :value, :find_or_create => true
  validates :value, :presence => true, :uniqueness => true
end
