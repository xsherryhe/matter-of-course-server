class CommentsController < ApplicationController
  before_action :authenticate_user!

  def index
    @commentable = commentable_from_params
    return head :unauthorized unless current_user.authorized_to_view?(@commentable)

    @comments = @commentable.comments.with_includes
    respond_with @comments, user: current_user
  end

  def create
    @commentable = commentable_from_params
    return head :unauthorized unless current_user.authorized_to_view?(@commentable)
    return render_not_accepting_error unless @commentable.accepting_comments?

    @comment = current_user.comments.build(comment_params.merge(commentable: @commentable))
    if @comment.save
      respond_with @comment, authorized: true
    else
      render json: @comment.simplified_errors, status: :unprocessable_entity
    end
  end

  def update
    @comment = Comment.find(params[:id])
    return head :unauthorized unless current_user.authorized_to_edit?(@comment)

    if @comment.update(comment_params)
      render json: @comment, authorized: true
    else
      render json: @comment.simplified_errors, status: :unprocessable_entity
    end
  end

  def destroy
    @comment = Comment.find(params[:id])
    return head :unauthorized unless current_user.authorized_to_edit?(@comment)

    @comment.destroy
    head :ok
  end

  private

  def comment_params
    params.require(:comment).permit(:body)
  end

  def commentable_from_params
    params[:commentable_type].classify.constantize.find(params[:commentable_id])
  end

  def render_not_accepting_error
    render json: { error: 'Comments are not accepted at this time.' }, status: :unprocessable_entity
  end
end
