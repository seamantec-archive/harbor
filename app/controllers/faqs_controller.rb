class FaqsController < ApplicationController
  before_action :authenticate_user!, except: [:list]
  before_action :find_topic, except: [:list, :index, :show, :new, :create, :update, :destroy]
  layout "static", only: [:list]

  def list
    @markdown = Redcarpet::Markdown.new(Redcarpet::Render::HTML)
    @topics = FaqTopic.asc(:list_position)
  end

  def index
    authorize! :show, FaqTopic
    @markdown = Redcarpet::Markdown.new(Redcarpet::Render::HTML)
    @topics = FaqTopic.asc(:list_position)
  end

  def new
    authorize! :create, FaqTopic
    @topic = FaqTopic.new
  end

  def create
    authorize! :create, FaqTopic
    @topic = FaqTopic.new({ name: faq_params[:name], previous_list_position: FaqTopic.count + 1, list_position: FaqTopic.count + 1 })
    if @topic.save
      redirect_to faqs_path
    else
      render action: "new"
    end
  end

  def show
    authorize! :show, FaqTopic
    @topic = FaqTopic.find(params[:id])
  end

  def edit
    authorize! :update, FaqTopic
    @topic = FaqTopic.find(params[:id])
  end

  def update
    authorize! :update, FaqTopic
    @topic = FaqTopic.find(params[:id])
    if @topic.update_attributes(name: faq_params[:name])
      redirect_to faqs_path
    else
      render action: "edit"
    end
  end

  def destroy
    authorize! :delete, FaqTopic
    FaqTopic.find(params[:id]).destroy
    redirect_to faqs_path
  end

  def new_question
    authorize! :create, FaqQuestion
    @question = FaqQuestion.new
  end

  def create_question
    authorize! :create, FaqQuestion
    @question = @topic.faq_questions.new({ question: faq_params[:question], answer: faq_params[:answer], previous_list_position: @topic.faq_questions.count + 1, list_position: @topic.faq_questions.count + 1 })
    if @question.save
      redirect_to faqs_path
    else
      render action: "new_question"
    end
  end

  def show_question
    authorize! :create, FaqQuestion
    @question = @topic.faq_questions.find(params[:id])
  end

  def edit_question
    authorize! :create, FaqQuestion
    @question = @topic.faq_questions.find(params[:id])
  end

  def update_question
    authorize! :update, FaqQuestion
    @question = @topic.faq_questions.find(params[:id])
    if @question.update_attributes({ question: faq_params[:question], answer: faq_params[:answer] })
      redirect_to faqs_path
    else
      render action: "edit_question"
    end
  end

  def destroy_question
    authorize! :delete, FaqQuestion
    @topic.faq_questions.find(params[:id]).destroy
    redirect_to faqs_path
  end

  def topic_change
    @topic.update_attributes({ previous_list_position: @topic.list_position, list_position: params[:list_position].to_i })
    render nothing: true
  end

  def question_change
    question = @topic.faq_questions.find(params[:id])
    question.update_attributes({ previous_list_position: question.list_position, list_position: params[:list_position].to_i })
    render nothing: true
  end

  def question_topic_change
    question = @topic.faq_questions.find(params[:id])
    new_questions = FaqTopic.find(params[:new_topic_id]).faq_questions
    new_question = new_questions.new({ question: question.question, answer: question.answer, previous_list_position: new_questions.count + 1, list_position: new_questions.count + 1 })
    if new_question.save
      question.destroy
      render text: new_question._id
    end
  end  

  private
  def faq_params
    if params.has_key?("faq_topic")
      params.require(:faq_topic).permit(:name, :list_position)
    elsif params.has_key?("faq_question")
      params.require(:faq_question).permit(:list_position, :question, :answer, :topic_id)
    else
      params
    end
  end

  def find_topic
    if params.has_key?("topic_id")
      @topic = FaqTopic.find(params[:topic_id])
    elsif params.has_key?("id")
      @topic = FaqTopic.find(params[:id])
    else
      params
    end
  end

end
