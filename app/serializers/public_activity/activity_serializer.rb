module PublicActivity
  class ActivitySerializer < ActiveModel::Serializer
  attributes(:id, :trackable_id, :trackable_type,
             :owner_id, :owner_type, :key,
             :recipient_id, :recipient_type, :created_at, :updated_at)

    has_one :owner
    has_one :recipient, serializer: SimpleGroupSerializer
    has_one :trackable
  end
end
