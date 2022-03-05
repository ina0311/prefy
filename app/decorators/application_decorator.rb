class ApplicationDecorator < Draper::Decorator
  def image
    case
    when object.image.present?
      object.image
    when object.respond_to?(:album)
      album.image
    else
      'default_image.png'
    end
  end
end
