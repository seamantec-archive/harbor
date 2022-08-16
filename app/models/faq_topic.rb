class FaqTopic
  include Mongoid::Document
  include Mongoid::Timestamps

  field :name, type: String
  field :list_position, type: Integer
  field :previous_list_position, type: Integer
  embeds_many :faq_questions

  validates_presence_of :name

  after_update do
    if self.previous_list_position < self.list_position
      FaqTopic.where(:list_position.gt => self.previous_list_position, :list_position.lte => self.list_position).each do |doc|
        if doc != self
          doc.update_attributes({ previous_list_position: doc.list_position - 1, list_position: doc.list_position - 1 })
        end
      end
    elsif self.previous_list_position > self.list_position
      FaqTopic.where(:list_position.gte => self.list_position, :list_position.lt => self.previous_list_position).each do |doc|
        if doc != self
          doc.update_attributes({ previous_list_position: doc.list_position + 1, list_position: doc.list_position + 1 })
        end
      end
    end
  end

  before_destroy do
    FaqTopic.where(:list_position.gt => self.list_position).each do |doc|
      doc.update_attributes({ previous_list_position: doc.list_position - 1, list_position: doc.list_position - 1 })
    end
  end

  def to_page_id
    "#{name.downcase.gsub(/[!*'();:@&=+$,\/?#\[\]]/, "").gsub(" ", "-")}-#{id}"
  end
end