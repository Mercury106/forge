ActiveAdmin.register_page "Dashboard" do

  menu :priority => 1, :label => proc{ I18n.t("active_admin.dashboard") }

  content :title => proc{ I18n.t("active_admin.dashboard") } do

    div :class => "news" do
      h2 'News'
      news = NewsItem.limit(20).order(:created_at => :desc)
      news.each do |news_item|
        div :class => 'news' do
          render 'news_item', :item => news_item
        end
      end
    end

    div :class => "jobs" do
      br
      h2 "Open sidekiq UI"
        a 'Sidekiq', href: '/sidekiq', target: '_blank'
    end

    script do
      %Q(
        setInterval(function(){
          $('.news').load('/admin .news')
        }, 5000)
      ).html_safe
    end

    div :id => "graph" do

    end

  end
end
