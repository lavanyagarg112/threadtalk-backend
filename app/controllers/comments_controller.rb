# app/controllers/comments_controller.rb
class CommentsController < ApplicationController
  before_action :set_post
  before_action :set_comment, if: -> { params[:comment_id].present? }

  # List comments (including replies) for a post or a comment.
  def index
    @comments = if @comment
                  @comment.replies
                else
                  @post.comments.where(parent_id: nil)
                end

    render json: @comments.map { |comment| 
      comment.as_json.merge(replies: comment.nested_replies)
    }
  end

  # Create a new comment or reply to an existing comment.
  def create
    @comment = if params[:comment_id].present?
                 parent_comment = Comment.find(params[:comment_id])
                 reply = parent_comment.replies.new(comment_params)
                 reply.post = parent_comment.post
                 reply
               else
                 @post.comments.new(comment_params)
               end

    @comment.user = User.find(comment_params[:user_id])

    if @comment.save
      render json: @comment, status: :created
    else
      render json: @comment.errors, status: :unprocessable_entity
    end
  end

  # Destroy a comment.
  def destroy
    comment = Comment.find(params[:id])
    if comment.destroy
      render json: { message: 'Comment was successfully deleted.' }, status: :ok
    else
      render json: { errors: comment.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def set_post
    if params[:comment_id].present?
      parent_comment = Comment.find(params[:comment_id])
      @post = parent_comment.post
    else
      @post = Post.find(params[:post_id])
    end
  end

  def set_comment
    @comment = Comment.find(params[:comment_id])
  end

  def comment_params
    params.require(:comment).permit(:content, :parent_id, :user_id, :author_name, :username)
  end
end
