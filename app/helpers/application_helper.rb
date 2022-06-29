module ApplicationHelper
  def image_svg_tag(filename, options = {})
    file = File.read(Rails.root.join('app', 'assets', 'images', filename))
    doc = Nokogiri::HTML::DocumentFragment.parse(file)
    svg = doc.at_css('svg')
    svg['class'] = options[:class] if options[:class].present?
    doc.to_html.html_safe
  end

  def default_meta_tags
    {
      site: 'Prefy',
      title: 'より簡単に好みに合わせてプレイリストをSpotifyで作ろう',
      reverse: false,
      separator: '|',   #Webサイト名とページタイトルを区切るために使用されるテキスト
      description: 'Spotifyのプレイリストをフォローアーティストのデータをもとに自動で作ります。自分でプレイリストを作成するのが面倒くさい方、更新されるプレイリストが目新しいさがなくなった方におすすめ',
      keywords: 'Spotify, playlist, プレイリスト, 面倒くさい',   #キーワードを「,」区切りで設定する
      canonical: request.original_url,   #優先するurlを指定する
      noindex: ! Rails.env.production?,
      icon: [                    #favicon、apple用アイコンを指定する
        { href: image_url('icon.svg') },
        { href: image_url('icon.svg'), rel: 'apple-touch-icon', sizes: '180x180', type: 'image/png' },
      ],
      og: {
        site_name: 'Prefy',
        title: 'より簡単に好みに合わせてプレイリストをSpotifyで作ろう',
        description: 'Spotifyのプレイリストをフォローアーティストのデータをもとに自動で作ります。自分でプレイリストを作成するのが面倒くさい方、更新されるプレイリストが目新しいさがなくなった方におすすめ', 
        type: 'website',
        url: request.original_url,
        image: image_url('icon.png'),
        locale: 'ja_JP',
      }
    #   twitter: {
    #     card: 'summary_large_image',
    #     site: '@ツイッターのアカウント名',
    #   }
    #   fb: {
    #     app_id: '自身のfacebookのapplication ID'
    #   }
    }
  end
end
