require 'sinatra'
require 'sinatra/reloader'

set :sessions, true

helpers do
  def calculate_total(cards)
    arr= cards.map{|element| element[1]}

    total = 0
    arr.each do |a|
      if a == "A"
        total +=11
      else
        total += a.to_i == 0 ? 10 : a.to_i
      end
    end

    #correct for Aces
    arr.select{|element| element == "A"}.count.times do
      break if total <=21
      total -= 10
    end

    total
  end
  #calculate_total(session[:dealers_cards]) => 20



def card_image(card) #['H','4']
  suit = case card[0]
    when 'H' then 'hearts'
    when 'D' then 'diamonds'
    when 'C' then 'clubs'
    when 'S' then 'spades'
  end


  value = card[1]
  if ['J', 'Q', 'K','A'].include(value)
    value = case card[1]
      when 'J' then 'jack'
      when 'Q' then 'queen'
      when 'K' then 'king'
      when 'A' then 'ace'
    end
  end

  "<img src='/images/cards/#{suit}_#{value}.jpg'>"
end
end



before do
  @show_hit_or_stay_buttons = true
end


get '/' do
  if session[:player_name]
    redirect '/game'
  else
    redirect '/new_player'
  end
end

get '/new_player' do
  erb :new_player
end

post '/new_player' do
  # "This is a post of '#{params[:player_name]}'"
  session[:player_name]=params[:player_name]
  redirect '/game'
end

get '/game' do
  #create a deck and put it in session
  suits = ['H', 'D','C','S']
  values = '2','3','4','5','6','7','8','9','10','J','Q','K','A'
  session[:deck]=suits.product(values).shuffle! #[ ['H','9'], ['C','K']...]
  #deal cards
  session[:dealer_cards] = []
  session[:player_cards] = []
  session[:dealer_cards] << session[:deck].pop
  session[:player_cards] << session[:deck].pop
  session[:dealer_cards] << session[:deck].pop
  session[:player_cards] << session[:deck].pop
    #dealer cards
    #player cards
  erb :game
end

post '/game/player/hit' do
  session[:player_cards] << session[:deck].pop
  if calculate_total(session[:player_cards]) > 21
    @error = "Sorry, it looks like you busted."
    @show_hit_or_stay_buttons = false
  end
  erb :game
end

post '/game/player/stay' do
  @success = "You have chosen to stay"
  @show_hit_or_stay_buttons = false
  erb :game
end