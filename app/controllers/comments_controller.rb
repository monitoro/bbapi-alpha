class CommentsController < ApplicationController
  before_action :set_commentable
  before_action :set_comment, only: [:show, :update, :destroy]
  before_filter :authenticate_user!

  def index
    obj = {comments:[]}
    
    current_page = (params[:page].to_i.is_a? Integer) ? (params[:page].to_i > 0 ? params[:page].to_i : 1) : 1
    @comments = @commentable.comments.page(current_page)

    @comments.each {
      |comment| obj[:comments].push({
        id: comment.id,
        content: comment.content,
        create_at: comment.created_at,
        writer: {
          email: comment.writer.email
        }
      })
    }

    if @commentable.comments.page(current_page + 1).count > 0
      obj['next'] = current_page + 1
    end

    render json: obj
  end

  def show
    @comment = Comment.find(params[:id])
    render json: @comment
  end

  def create
    @comment = @commentable.comments.build(comment_params)
    @comment.writer = current_user
    if @comment.save
      render json: @comment, status: :created
    else
      render json: @comment.errors, status: :unprocessable_entity
    end
  end

  def update
    @comment = Comment.find(params[:id])

    if @comment.update(comment_params)
      head :no_content
    else
      render json: @comment.errors, status: :unprocessable_entity
    end  	
  end

  def destroy
    @comment.destroy

    head :no_content	
  end

  private

  def set_commentable
    @commentable = params[:commentable_type].classify.constantize.send('find', params[:commentable_id])
  end

  def set_comment
    @comment = @commentable.comments.find(params[:comment_id])
  end

  def comment_params
    params.require(:comment).permit(:content)
  end  
end
