class PostsController < ApplicationController
  before_action :authenticate_user!

  def index
    @postable = postable_from_params
    return head :unauthorized unless current_user.authorized_to_view_details?(@postable)

    @posts = @postable.posts.on_page(params[:page] || 1)
    respond_with @posts
  end

  def show
    @post = Post.find(params[:id])
    return head :unauthorized unless current_user.authorized_to_view?(@post)

    render json: @post.as_json_with_details(authorized: current_user.authorized_to_edit?(@post))
  end

  def create
    @postable = postable_from_params
    return head :unauthorized unless current_user.authorized_to_view_details?(@postable)

    @post = current_user.posts.build(post_params.merge(postable: @postable))

    if @post.save
      render json: @post.as_json_with_details(authorized: true)
    else
      render json: @post.simplified_errors, status: :unprocessable_entity
    end
  end

  def update
    @post = Post.find(params[:id])
    return head :unauthorized unless current_user.authorized_to_edit?(@post)

    if @post.update(post_params)
      render json: @post.as_json_with_details(authorized: true)
    else
      render json: @post.simplified_errors, status: :unprocessable_entity
    end
  end

  def destroy
    @post = Post.find(params[:id])
    return head :unauthorized unless current_user.authorized_to_edit?(@post)

    @post.destroy
    head :ok
  end

  private

  def post_params
    params.require(:post).permit(:title, :body)
  end

  def postable_from_params
    params[:postable_type].classify.constantize.find(params[:postable_id])
  end
end
