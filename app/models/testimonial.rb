class Testimonial
  include Mongoid::Document
  include Mongoid::Timestamps

  field :from, type: String
  field :full_text, type: String
  field :quote, type: String
  field :image_path, type: String
  field :link, type: String

end
