class TitsController < ApplicationController

  def show
    @tits = Tits.find(params[:id])
  end

  def pending
    @tits_list = Tits.pending
    render 'tits'
  end

  def published
    #@tits_list = Tits.published
    #render 'tits'
  end

  def rejected
    @tits_list = Tits.rejected
    render 'tits'
  end

  def approved
    @tits_list = Tits.approved
    render 'tits'
  end

  def create
    Resque.enqueue(NewTits, params[:link])
    render :nothing => true
  end

  def approve
    @tits = Tits.find(params[:id])
    @tits.state = :approved unless @tits.state == :published
    @tits.save!
  end

  def reject
    @tits = Tits.find(params[:id])
    @tits.state = :rejected unless @tits.state == :published
    @tits.save!
  end

  layout 'admin'
end
