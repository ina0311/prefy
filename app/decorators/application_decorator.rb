class ApplicationDecorator < Draper::Decorator
  def image
    if object.image.present?
      object.image
    elsif object.respond_to?(:album)
      album.image
    else
      'default_image.png'
    end
  end
end
