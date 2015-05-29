require 'sinatra'
require 'pg'

def db_connection
  begin
    connection = PG.connect(dbname: "news_aggregator_development")
#  rescue PG::UniqueViolation
    yield(connection)
  ensure
    connection.close
  end
end

def submission
  [params["title"], params["url"], params["description"]]
end

get '/articles' do
  news = db_connection { |conn| conn.exec("SELECT title, url, description FROM articles")}
  erb :index, locals: {news: news}
end

get '/articles/new' do
  erb :form
end

post'/articles/new' do
  db_connection do |conn|
    conn.exec_params("INSERT INTO articles (title, url, description) VALUES ($1, $2, $3)", submission)
  end

  redirect '/articles'
end
