class ApplicationDecorator < Draper::Decorator
  # Define methods for all decorated objects.
  # Helpers are accessed through `helpers` (aka `h`). For example:
  #
  #   def percent_amount
  #     h.number_to_percentage object.amount, precision: 2
  #   end
  def image
    case
    when object.image.present?
      object.image
    when object.respond_to?(:album)
      album.image
    end
  end
end
