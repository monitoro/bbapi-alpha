class CommentsController < ApplicationController
  before_action :set_commentable
  before_action :set_comment, only: [:show, :update, :destroy]
  before_filter :authenticate_user!

  def index
    per_request = params[:limit] || 3
    obj = {comments:[]}
    @comments = params[:next] ? 
                @commentable.comments.where("id < ?", params[:next]).reverse.take(per_request).reverse :
                @commentable.comments.order(id: :desc).limit(per_request).reverse

    @comments.each {
      |comment| obj[:comments].push({
        id: comment.id,
        content: comment.content,
        create_at: comment.created_at,
        writer: {
          email: comment.writer.email,
          avatar_url: comment.writer.avatar.url
        }
      })
    }

    if @comments.length > 0
      if @commentable.comments.where("id < ?", @comments.first.id).length > 0
        obj['next'] = @comments.first.id
      end
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
