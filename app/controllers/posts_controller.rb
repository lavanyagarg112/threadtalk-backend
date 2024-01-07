class PostsController < ApplicationController

    def index
        @posts = Post.all
        render json: @posts
      end

    def create
      post = Post.new(post_params)
      if post.save
        render json: post, status: :created
      else
        render json: post.errors, status: :unprocessable_entity
      end
    end

    def show
        @post = Post.find_by(id: params[:id])
        if @post
          render json: @post
        else
          render json: { error: "Post not found" }, status: :not_found
        end
      end
  
    private
  
    def post_params
      params.require(:post).permit(:title, :description, :user_id, :author_name)
    end
  end
  