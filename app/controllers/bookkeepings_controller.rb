class BookkeepingsController < ApplicationController
  before_action :set_group, only: [:index, :index_between, :create, :calculate]
  before_action :set_bookkeeping, only: [:show, :update, :destroy, :add_proof, :remove_proof]

  # GET /bookkeepings
  # GET /bookkeepings.json
  def index
    @bookkeepings = @_bookkeepings = @group.bookkeepings

    if params[:start_date]
      @_bookkeepings = @bookkeepings.where("issue_date >= ?", params[:start_date])
    end
    if params[:end_date]
      @_bookkeepings = @_bookkeepings.where("issue_date < ?", Date.parse(params[:end_date]) + 1.day)
    end

    bookkeepings = {bookkeepings:[]}
    per_request = params[:limit] || 3
    @_bookkeepings = params[:next] ? 
                @_bookkeepings.where("id < ?", params[:next]).reverse.take(per_request).reverse :
                @_bookkeepings.order(id: :desc).limit(per_request).reverse

    @_bookkeepings.each {
      |bookkeeping| bookkeepings[:bookkeepings].push({
        id: bookkeeping.id,
        writer: bookkeeping.writer,
        content: bookkeeping.content,
        created_at: bookkeeping.created_at,
        issue_date: bookkeeping.issue_date,
        account_title: bookkeeping.account_title,
        remark: bookkeeping.remark,
        operator: bookkeeping.operator,
        amount: bookkeeping.amount,
        issuer: {
          id:bookkeeping.issuer.id,
          username:bookkeeping.issuer.username,
          avatar_url:bookkeeping.issuer.avatar.url
        },
        liker_ids: bookkeeping.liker_ids,
        likes_count: bookkeeping.likes_count,
        comments_count: bookkeeping.comments.length
      })
    }

    if @_bookkeepings.length > 0
      if @bookkeepings.where("id < ?", @_bookkeepings.first.id).length > 0
        bookkeepings['next'] = @_bookkeepings.first.id
      end
    end

    render json: bookkeepings
  end

  def index_between
    end_date = Date.today.at_end_of_day
    
    case params[:between]
    when "week"
      start_date = end_date.at_beginning_of_week
    when "month"
      start_date = end_date.at_beginning_of_month
    when "year"
      start_date = end_date.at_beginning_of_year
    else
      return
    end    

    @bookkeepings = @group.bookkeepings.order(created_at: :desc)

    @bookkeepings = @bookkeepings.where("issue_date >= ?", start_date)
    @bookkeepings = @bookkeepings.where("issue_date < ?", end_date)

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

  def calculate_between
    end_date = Date.today.at_end_of_day
    
    case params[:between]
    when "week"
      start_date = end_date.at_beginning_of_week
    when "month"
      start_date = end_date.at_beginning_of_month
    when "year"
      start_date = end_date.at_beginning_of_year
    else
      return
    end    

    calc_query = Group.find(params[:group_id]).bookkeepings.
      where("issue_date >= ?", start_date).
      where("issue_date < ?", end_date)

    income = calc_query.where("operator = '+'").sum('amount')
    outlay = calc_query.where("operator = '-'").sum('amount')
    total = income - outlay

    render json: { start_date: start_date.strftime("%Y-%m-%d"), end_date: end_date.strftime("%Y-%m-%d"),  income: income, outlay: outlay, total: total }
  end


  def calculate
    start_date = params[:start_date]
    end_date = params[:end_date]

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
