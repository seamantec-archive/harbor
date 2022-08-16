class FaqQuestion
  include Mongoid::Document
  include Mongoid::Timestamps

  field :question, type: String
  field :answer, type: String
  field :list_position, type: Integer
  field :previous_list_position, type: Integer
  embedded_in :faq_topic

  validates_presence_of :question, :answer

  after_update do
    if self.previous_list_position < self.list_position
      self.faq_topic.faq_questions.where(:list_position.gt => self.previous_list_position, :list_position.lte => self.list_position).each do |doc|
        if doc != self
          doc.update_attributes({ previous_list_position: doc.list_position - 1, list_position: doc.list_position - 1 })
        end
      end
    elsif self.previous_list_position > self.list_position
      self.faq_topic.faq_questions.where(:list_position.gte => self.list_position, :list_position.lt => self.previous_list_position).each do |doc|
        if doc != self
          doc.update_attributes({ previous_list_position: doc.list_position + 1, list_position: doc.list_position + 1 })
        end
      end
    end
  end

  before_destroy do
    self.faq_topic.faq_questions.where(:list_position.gt => self.list_position).each do |doc|
      doc.update_attributes({ previous_list_position: doc.list_position - 1, list_position: doc.list_position - 1 })
    end
  end

  def to_page_id
    "#{question.downcase.gsub(/[!*'();:@&=+$,\/?#\[\]]/, "").gsub(" ", "-")}-#{id}"
  end
end