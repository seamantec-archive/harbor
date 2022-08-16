class StaticController < ApplicationController
  layout "static"

  def show
    @markdown = Redcarpet::Markdown.new(Redcarpet::Render::HTML)
    @faqs = FaqTopic.asc(:list_position)
    @testimonials = Testimonial.all.limit(4)
    # if user_signed_in? && current_user.is_admin?
    #   redirect_to dashboards_path
    #
    #
    # end
  end

  def about

  end

  def terms

  end

  def data_protection

  end

  def contact

  end

  def eula

  end

end
