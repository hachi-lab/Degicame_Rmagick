# -*- coding: utf-8 -*-

require 'rubygems'
require 'sinatra'

unless ENV['local']=='yes'
  require 'RMagick'
  include Magick
end

#require 'rubygems'
require 'json'
require 'rest_client'

$api_server = 'http://api2.dc-keisoku.com'
#$username = 'ume001'
#$password = 'ume001'

#sinatra
#ログインページ
get '/' do
    @title = 'Rmagick'
    @subtitle = 'Please login!'
erb :index
end


#プロジェクト選択画面
post '/select' do


#プロジェクト一覧を表示する為のくだり


$username = @params[:body1]
$password = @params[:body2]

  # デジカメ計速を利用するには，
  # 最初にログインして，キー（16進40桁）を受け取る
  # 以下の情報取得には，このキーを利用する
  puts '=== /user/login'
  $key = RestClient.post("#{$api_server}/user/login",
                         username: $username, 
                         password: $password)
  
  # プロジェクト一覧を取得する
  # JSON 形式なので，パースする
  puts '=== /project/list'
  ret = RestClient.post("#{$api_server}/project/list",
                        key: $key)
  @projects = JSON.parse(ret)

  # 表示
  # @a = Array.new
  # num = 0
  # projects.each do |project|
  #  #puts format('%3d: %s', project["id"], project["title"])
  #  #project = ハッシュの配列
  #  @a[num] = project["id"].to_s + ":" + project["title"].to_s
  #  num += 1
  #  #    p @a[num]
  # end
  
  @title = 'Rmagick'
  @subtitle = '編集・表示する画像のidを入力してください'

  erb :main
end


post '/id' do
  #画像のURLを取得するくだり
  # プロジェクト番号を入力させる
  project_id = @params[:body3]
  
  # 指定したプロジェクトが持つ画像一覧を取得する
  puts '=== /project/images'
  ret = RestClient.post("#{$api_server}/project/images",
                        key: $key,
                        project_id: project_id)
  images = JSON.parse(ret)

  @imagelist = []
  images.each do |image|
    url = RestClient.post("#{$api_server}/image/image_url",
                          key: $key,
                          image_id: image["id"])
    @imagelist << {id: image["id"], url: url}
  end
    
  # 画像のURLを取得して表示する
  # 取得したURLは一定時間が経過すると無効化されるので注意すること
  # @b = Array.new
  # num = 0
  # images.each do |image|
  #  url = RestClient.post("#{$api_server}/image/image_url",
  #                        key: $key,
  #                        image_id: image["id"])
  #  @b[num] = "[" + image["id"].to_s + "]" + ":" + url.to_s
  #  num += 1
  #  
  #  puts "#{image["id"]} : #{url}"
  #end

  @title = @params[:body3]
  @subtitle = "画像のURLです"
  @wordword = "URLをフォームに入力することで編集した画像を表示します"
  
  erb :number
end

#画像表示
post '/pic' do

WIDTH = 240
HEIGHT = 300

#画像編集
def create_pic

picpic = @params[:body4]
image = Magick::Image.read(picpic).first

image.format = 'JPEG'

canvas = image
dr = Draw.new

# 楕円
dr.stroke('red')
dr.stroke_width(3)
dr.fill_opacity(0)
dr.ellipse(120, 150, 80, 120, 0, 270) # x, y, widgh, height, 角度
dr.stroke('green')
dr.ellipse(120, 150, 70, 130, 0, 290) # 少し形変える

# 十字
dr.stroke('purple')
dr.stroke_width(5)
dr.line(0, HEIGHT/2, WIDTH, HEIGHT/2) # 横線
dr.line(WIDTH/2, 0, WIDTH/2, HEIGHT) # 縦線

# 斜線
dr.stroke('blue')
dr.stroke_width(1)
for y in 0...20
  for x in 0...10
    dr.line(x*10, y*10, x*10+10, y*10+10)
  end
end

# テキスト
dr.font = '/Library/Fonts/Arial.ttf'
dr.stroke('transparent')
dr.fill('black')
dr.pointsize = 12 # 文字サイズ
dr.text(180, 140, "Start")

# いったん描画
dr.draw(canvas)

# 文字サイズを変えるために新しいDrawを使う
dr = Draw.new
dr.font = '/Library/Fonts/Arial.ttf'
dr.stroke('transparent')
dr.fill('black')
dr.pointsize = 20 # 文字サイズ
dr.text(130, 50, "End")

# 描画、保存
dr.draw(canvas)
#canvas.write('img-result.png')

canvas.to_blob  #=> バイナリデータ化
end

  blob = create_pic
  content_type "image/png"
  blob  #=> バイナリデータを直接表示
end
