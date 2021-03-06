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
	@db.execute 'CREATE TABLE IF NOT EXISTS Posts
	(
		id INTEGER PRIMARY KEY AUTOINCREMENT,
		created_date DATE,
		content TEXT,
		username TEXT
	)'
	@db.execute 'CREATE TABLE IF NOT EXISTS Comments
	(
		id INTEGER PRIMARY KEY AUTOINCREMENT,
		created_date DATE,
		content TEXT,
		name TEXT,
		post_id INTEGER
	)'
end

get '/new' do
	erb :new
end

get '/' do
	@results = @db.execute 'select * from Posts order by id desc'
	erb :insex 
end

post '/new' do
	@content = params[:content]
	@username = params[:username]

	if (@content.length <= 0 or @username.length < 0)
		@error = 'Type all this area'
		return erb :new
	end	
	@db.execute 'insert into Posts (content, username, created_date) values (?, ?, datetime())', [@content, @username]
	
	#перенаправление!!!!
	redirect to('/')
end

get '/details/:post_id' do
	post_id = params[:post_id]

	results = @db.execute 'select * from Posts where id = ?',[post_id]
	@row = results[0]

	@comments = @db.execute 'select * from Comments where post_id=? order by id',[post_id]

	erb :details
end

post '/details/:post_id' do
	post_id = params[:post_id]
	content = params[:content]
	name = params[:name]

	@db.execute 'insert into Comments (name, content, created_date, post_id) 
				 values (?, ?, datetime(),?)', [name, content, post_id]
	

	redirect to('/details/' + post_id)
end