class PublicController < ApplicationController

  def index
    if current_user
      render 'ui/index', :layout => "application"
    else
      render 'index'
    end
  end

  def showcase
    render 'showcase'
  end

  before_filter :load_user
  def load_user
    @user = User.new

    if Rails.env.development?
      seed = (rand*1000000).to_i
      @user.name = "user-#{seed}"
      @user.email = "#{seed}@riothq.com"
      @user.password = "testing"
    end
  end

  def page
    page = params[:format].present? ? "#{params[:page]}.#{params[:format]}" : params[:page]
    path = File.join(Rails.root, "app", "views", "public", "_#{page}.html.erb")
    if File.exist? path
      render 'index', formats: [:html]
    else
      render 'public/404', formats: [:html], status: 404
    end
  end

  def blog
    page = params[:page]
    page_file = File.join(Rails.root, 'app', 'views', 'public', 'blog', page)
    if Dir.glob(page_file + ".*").count > 0
      render "public/blog/#{page}"
    else
      render 'public/404', formats: [:html], status: 404
    end
  end
end
