# Prefy

## サービス概要
 spotifyでフォローしているアーティストのみで自分の好きな条件でプレイリストを作成するサービスです。

<br>

## メインのターゲットユーザー
- 日常的にspotifyを利用して好きなアーティストをフォローしている。
- リコメンドされるの知らない曲をスキップすることが多く、元から好きな曲を聞くことが多い。
- たまには元から好きなアーティストのみのプレイリストを聞きたい。
- 自分で曲を集めてプレイリストを作るのが面倒に感じる。

<br>

## ユーザーが抱える課題
- spotifyにフォローしているアーティストのみでプレイリストを作る機能がない。
- リコメンドされるプレイリストには何曲かは聞いたことないもしくは好みではない曲が入る。
- リコメンドされるプレイリストの傾向が最近の好みに偏り、同じようなプレイリストが多くなってしまう。

<br>

## 解決方法
***
spotifyのAPIを使ってユーザーの情報を取得し,ジャンルや時代などの条件を指定してフォローしているアーティストのみのプレイリストを自動で作成する。

<br>

## 実装予定の機能
- フォローしているアーティストで構成されるプレイリストを作成、編集できる。
- プレイリストに作成する条件（ジャンル、時代、曲数、再生時間など）を指定してプレイリストを作成、編集できる。
- 作成したプレイリストを保存、ツイッターに投稿できる。
- アーティスト、曲、プレイリストを検索し、フォローできる.
- フォローしているアーティスト、保存したプレイリストの一覧を閲覧できる

<br>

## なぜこのサービスを作りたいのか？
自分自身が数あるサブスクの中でもspotifyを使っている理由として、精度の高いリコメンド機能があります。そのおかげでさまざまな新しい音楽に出会えており、何年も愛用しています。
しかし、たまには元から好きなアーティストや今は聞いていないけどふと聞きたくなる曲を集めたプレイリストがほしいと思いましたが、自分で一曲ずつプレイリストに追加するのは面倒なので自動でプレイリストを作成するサービスを作ろうと思いました。

<br>

## 画面遷移図
https://www.figma.com/file/P52rSSuHjJaxjzYG62WVtY/Prefy%E7%94%BB%E9%9D%A2%E9%81%B7%E7%A7%BB%E5%9B%B3?node-id=0%3A1

<br>

## ER図
https://drive.google.com/file/d/16nh0zLl0UZNXBo2g7SKOq9SAuenHPJPZ/view?usp=sharing