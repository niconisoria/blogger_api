class ArticlesController < ApplicationController
  skip_before_action :authorize!, only: [:index, :show]

  def index
    articles = paginate Article.recent.page(params[:page]).per(params[:per_page])
    render json: articles
  end

  def show
    render json: Article.find(params[:id])
  end

  def create
    article = current_user.articles.build(article_params)
    article.save!
    render json: article, status: :created
  rescue StandardError
    render json: article, status: :unprocessable_entity, error: true
  end

  def update
    article = current_user.articles.find(params[:id])
    article.update!(article_params)
    render json: article, status: :ok
  rescue ActiveRecord::RecordNotFound
    authorization_error
  rescue ActiveRecord::RecordInvalid
    render json: article, status: :unprocessable_entity, error: true
  end

  def destroy
    article = current_user.articles.find(params[:id])
    article.destroy
    head :no_content
  rescue ActiveRecord::RecordNotFound
    authorization_error
  end

  private

  def article_params
    params.require(:data).require(:attributes).permit(:title, :content, :slug) || ActionController::Parameters.new
  end

  def serializer
    ArticleSerializer
  end
end
