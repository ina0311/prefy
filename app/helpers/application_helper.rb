module ApplicationHelper
  def image_svg_tag(filename, options = {})
    file = File.read(Rails.root.join('app', 'assets', 'images', filename))
    doc = Nokogiri::HTML::DocumentFragment.parse(file)
    svg = doc.at_css('svg')
    svg['class'] = options[:class] if options[:class].present?
    doc.to_html.html_safe
  end
end
