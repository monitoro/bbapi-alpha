class BookkeepingSerializer < ActiveModel::Serializer
  attributes :id, :issue_date, :operator, :remark, :amount, :content, :likes_count, :created_at, :updated_at
  has_one :issuer
  has_one :writer
  has_one :account_title
  has_many :proofs
  has_many :likers, embed: :ids
end
