# Disable for all serializers (except ArraySerializer)
ActiveModel::Serializer.root = false

#FIXME: This doesn't appear to be working after upgrading.  Had to specifiy root false in serializer
# Disable for ArraySerializer
ActiveModel::ArraySerializer.root = false
