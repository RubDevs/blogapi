class PostSerializer < ActiveModel::Serializer
  attributes :id, :title, :content, :published, :author

  def author
    user = self.object.user
    {
      email: user.email,
      name: user.name,
      id: user.id

    }
  end
end
