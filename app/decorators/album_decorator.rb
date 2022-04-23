class AlbumDecorator < ApplicationDecorator
  delegate_all

  def image
    image? ? album.image : 'default_image.png'
  end
end
