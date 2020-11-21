class ArticlesController < ApplicationController
  before_action :set_article, only: [:show, :edit, :update, :destroy]

  PER_PAGE = 2

  def index
    @articles = Article.paginate(page: params[:page], per_page: PER_PAGE).order("created_at DESC")
  end

  def show
  end

  def new
    @article = current_user.articles.build
  end

  def edit
  end

  def create
    @article = current_user.articles.build(article_params)
    if @article.save
      flash[:notice] = "Article was created successfully."
      redirect_to @user
    else
      render "new"
    end
  end

  def update
    if @article.update(article_params)
      flash[:notice] = "Article was updated successfully."
      redirect_to @user
    else
      render "edit"
    end
  end

  def destroy
    @article.destroy
    flash[:notice] = "Article was deleted successfully."
    redirect_to @user
  end

  private

  def set_article
    @article = Article.find(params[:id])
  end

  def article_params
    params.require(:article).permit(:title, :description)
  end

  def current_user
    @user = User.find(session[:user_id])
  end
end
