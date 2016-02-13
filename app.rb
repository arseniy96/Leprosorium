#encoding: utf-8
require 'rubygems'
require 'sinatra'
require 'sinatra/reloader'
require 'sqlite3'

def init_db
	@db = SQLite3::Database.new 'leprosorium.db'
	@db.results_as_hash = true
end

before do
	init_db
end

configure do
  init_db
  @db.execute 'CREATE TABLE IF NOT EXISTS Posts(
							"id" INTEGER PRIMARY KEY AUTOINCREMENT,
							"login" TEXT,
							"created_date" DATE,
							"content" TEXT
							)'
	@db.execute 'CREATE TABLE IF NOT EXISTS Comments(
							"id" INTEGER PRIMARY KEY AUTOINCREMENT,
							"login" TEXT,
							"created_date" DATE,
							"content" TEXT,
							"post_id" INTEGER
							)'
end

get '/' do
  @results = @db.execute 'select * from Posts order by id desc'
	erb :index
end

get '/new' do
  erb :new
end

post '/new' do
	@content = params[:content]
  @login = params[:login]
  if @content.length == 0
		@error = 'Введите текст'
    return erb :new
  elsif @login.length == 0
    @error = 'Ведите логин'
    return erb :new
  else
    @db.execute 'insert into Posts(login, content, created_date) values (?, ?, datetime())', [login, content]
 		redirect to '/'
  end
end

get '/comments/:post_id' do
  post_id = params[:post_id]
	@results = @db.execute 'select * from Posts where id = ?', [post_id]
  @row = @results[0]

  @comments = @db.execute 'select * from comments where post_id = ? order by id', [post_id]

  erb :comments
end

post '/comments/:post_id' do
	post_id = params[:post_id]
  content = params[:content]
  login = params[:login]

	if content == ''
    @error = 'Введите текст комментария'
		erb :comments
  else
		@db.execute 'insert into Comments(login, content, created_date, post_id) values (?, ?, datetime(), ?)',
                [login,content, post_id]
		redirect to('/comments/'+post_id)
  end
end