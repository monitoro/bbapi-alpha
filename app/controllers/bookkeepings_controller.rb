class BookkeepingsController < ApplicationController
  before_action :set_group, only: [:index, :create, :calculate]
  before_action :set_bookkeeping, only: [:show, :update, :destroy, :add_proof, :remove_proof]

  # GET /bookkeepings
  # GET /bookkeepings.json
  def index
    @bookkeepings = @group.bookkeepings.order(created_at: :desc)

    if params[:start_date]
      @bookkeepings = @bookkeepings.where("issue_date >= ?", params[:start_date])
    end
    if params[:end_date]
      @bookkeepings = @bookkeepings.where("issue_date < ?", Date.parse(params[:end_date]) + 1.day)
    end

    render json: @bookkeepings
  end

  # GET /bookkeepings/1
  # GET /bookkeepings/1.json
  def show

    render json: @bookkeeping
  end

  # POST /bookkeepings
  # POST /bookkeepings.json
  def create
    @bookkeeping = @group.bookkeepings.new()
    @bookkeeping.attributes = bookkeeping_params
    @bookkeeping.writer_id = current_user.id
    if @bookkeeping.save
      render json: @bookkeeping, status: :created, location: @bookkeeping
    else
      render json: @bookkeeping.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /bookkeepings/1
  # PATCH/PUT /bookkeepings/1.json
  def update
    if @bookkeeping.update(bookkeeping_params)
      head :no_content
    else
      render json: @bookkeeping.errors, status: :unprocessable_entity
    end
  end

  # DELETE /bookkeepings/1
  # DELETE /bookkeepings/1.json
  def destroy
    @bookkeeping.destroy

    head :no_content
  end

  def calculate
    start_date = params[:start_date]
    end_date = params[:end_date]
    # income = Group.find(params[:group_id]).bookkeepings.where("issue_date between ? and ?", start_date, end_date).where("operator = '+'").sum('amount')    
    # outlay = Group.find(params[:group_id]).bookkeepings.where("issue_date between ? and ?", start_date, end_date).where("operator = '-'").sum('amount')    

    calc_query = Group.find(params[:group_id]).bookkeepings
    if start_date.present?
      calc_query = calc_query.where("issue_date >= ?", start_date)
    end
    if end_date.present?
      calc_query = calc_query.where("issue_date < ?", Time.parse(end_date) + 1.day)
    end
    income = calc_query.where("operator = '+'").sum('amount')
    outlay = calc_query.where("operator = '-'").sum('amount')
    total = income - outlay

    render json: { income: income, outlay: outlay, total: total }
  end

  def add_proof
    proof = @bookkeeping.proofs.build picture: params[:file]
    proof.user = current_user
    if proof.save
      render :json => proof
    else
      render json: {}, status: :unprocessable_entity
    end
  end

  def remove_proof
    proof = @bookkeeping.proofs.find(params[:proof_id])
    if proof.destroy
      render :json => { success: true }
    else
      render json: {}, status: :unprocessable_entity
    end  
  end

  def get_first_issue_date
    render :json => { issue_date: Bookkeeping.get_first_issue_date }
  end

  def like    
    bookkeeping = Bookkeeping.find(params['bookkeeping_id']) unless  params['bookkeeping_id'].nil?        
    unless bookkeeping.nil?
      bookkeeping.like! current_user
      render json: { result: "success"}
    end
  end

  def dislike
    bookkeeping = Bookkeeping.find(params['bookkeeping_id']) unless  params['bookkeeping_id'].nil?    
    unless bookkeeping.nil?
      bookkeeping.dislike! current_user
      render json: { result: "success"}
    end
  end

  private

  def set_group
    @group = Group.find(params[:group_id])
  end

  def set_bookkeeping
    @group = Group.find(params[:group_id])
    @bookkeeping = @group.bookkeepings.find(params[:id])
  end

  def bookkeeping_params
    params.require(:bookkeeping).permit(:group_id, :issue_date, :issuer_id, :operator, :account_title_id, :remark, :amount, :content, :proofs)
  end  
end
