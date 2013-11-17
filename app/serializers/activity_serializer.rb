class ActivitySerializer < ActiveModel::Serializer
  attributes(:id, :trackable_id, :trackable_type,
             :owner_id, :owner_type, :key,
             :recipient_id, :recipient_type, :created_at, :updated_at)
  
end
