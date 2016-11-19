class DiscussionsController < ApplicationController
  include UsesMetadata
  before_filter :we_dont_serve_images_here_google_bot
  before_filter :show_seed_threads, only: :show

  private

  def show_seed_threads
    @seed_threads = load_and_authorize(:discussion)
  end

  def we_dont_serve_images_here_google_bot
    if request.format == :png
      render :text => 'Not Found', :status => '404'
    end
  end
end
