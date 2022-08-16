class Role
  ROLES = %w[admin customer partner]
  include Mongoid::Document
  embedded_in :user
  field :role, type: String
  field :selected, type: Boolean, default: false
  validates_inclusion_of :role, in: ROLES, message: "Role is not valid"

  def selected=(param)
    if (param.is_a? String)
      case param
        when "1"
          self[:selected] = true
        when "0"
          self[:selected]= false
      end
    elsif (param.is_a? Boolean)
      self[:selected] = param
    end
  end
end
