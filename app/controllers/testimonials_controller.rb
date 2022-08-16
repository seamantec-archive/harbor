class TestimonialsController < ApplicationController
  before_action :authenticate_user!, except: [:index]

  def index
    @testimonials = Testimonial.all
  end

  def new
    @testimonial = Testimonial.new
    authorize! :create, @testimonial
  end

  def show
    redirect_to testimonials_path
  end

  def create
    @testimonial = Testimonial.new(testimonial_params)
    if @testimonial.save
      redirect_to testimonials_path
    else
      render action: "new"
    end
  end

  def destroy
    @testimonial = Testimonial.find(params[:id])
    @testimonial.destroy
    redirect_to testimonials_path
  end

  private
  def testimonial_params
    params.require(:testimonial).permit(:from, :full_text, :quote, :image_path)
  end
end
