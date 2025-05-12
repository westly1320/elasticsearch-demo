class SearchController < ApplicationController
  def create
    @result = search_for_posts

    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: turbo_stream.update('suggestions', partial: 'search/suggestions', locals: {results: @result})
      end
    end
  end

  private

  def search_for_posts
    if params[:query].blank?
      Post.all
    else
      Post.search(params[:query]).records
    end
  end
end
