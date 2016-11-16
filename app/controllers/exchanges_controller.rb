class ExchangesController < ApplicationController
  before_action do
    @exchange = Exchange.find_by_permalink!(params[:id]) if params[:id]
  end

  def index
    @exchanges = Exchange.all
  end

  def new
    @exchange = Exchange.new(match_at: 2.weeks.from_now, exchange_at: 4.weeks.from_now)
    @first_participant = Participant.new
  end

  def create
    @first_participant = Participant.new(safe_participant_params)
    @first_participant.admin = true

    @exchange = Exchange.new(safe_exchange_params)
    @exchange.participants << @first_participant

    if @exchange.save
      self.current_participant = @first_participant
      redirect_to exchange_path(@exchange)
    else
      render :new
    end
  end

  def show
    @participants = @exchange.participants.participating
    @participant = @exchange.participants.build
  end

  def edit
  end

  def update
    if @exchange.update_attributes(safe_exchange_params)
      redirect_to exchange_path(@exchange)
    else
      render :edit
    end
  end

  private

  def safe_exchange_params
    params.require(:exchange).permit(:title, :match_at, :exchange_at)
  end

  def safe_participant_params
    params[:exchange].require(:participant).permit(:name, :email_address)
  end
end
