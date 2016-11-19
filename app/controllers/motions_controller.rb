class MotionsController < ApplicationController
  include UsesMetadata
  before_filter :show_seed_threads, only: :show

  private

  def show_seed_threads
    @seed_threads = load_and_authorize(:motion).discussion
  end
end
