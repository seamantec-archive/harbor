class Ability
  include CanCan::Ability

  def initialize(user)

    if user
      can [:show, :edit, :update, :destroy, :change_password], User, :id => user.id
      can :list, User if user.is_admin?
      can :list_admins, User if user.is_admin?
      can :list_partners, User if user.is_admin?
      can :list_customers, User if user.is_admin?
      can :manage, User if user.is_admin?
      can :reset_password, User if user.is_admin?

      can :manage, Role if user.is_admin?
      can [:show], License, user_id: user.id
      can [:manage], License if user.is_admin?
      can [:manage], LicenseTemplate if user.is_admin?
      can [:create], LicensePool if user.is_admin?
      can [:list, :show], LicensePool if user.is_admin? || user.is_partner?
      can [:allocate_new], LicensePool, :user => user

      can :manage, Release if user.is_admin?

      can :manage, ProductCategory if user.is_admin?
      can :manage, ProductItem if user.is_admin?

      can :show, Order if user.is_admin?

      can :manage, Invoice if user.is_admin?
      can :manage, InvoiceArray if user.is_admin?

      can :manage, FaqTopic if user.is_admin?
      can :manage, FaqQuestion if user.is_admin?
      can :manage, AdminPanel if user.is_admin?
      can :manage, Report if user.is_admin?

      can [:list, :show, :destroy], Device, user: user
      can :manage, Device if user.is_admin?

      can :manage, Polar, user: user
      can :manage, Polar if user.is_admin?
      can :manage, LogFile, user: user
      can :manage, LogFile if user.is_admin?
      can :manage, NmeaLog, user: user
      can :manage, NmeaLog if user.is_admin?
      can :manage, Testimonial if user.is_admin?
      can :manage, Coupon if user.is_admin?
      can :manage, CouponGroup if user.is_admin?

    end
    # Define abilities for the passed in user here. For example:
    #
    #   user ||= User.new # guest user (not logged in)
    #   if user.admin?
    #     can :manage, :all
    #   else
    #     can :read, :all
    #   end
    #
    # The first argument to `can` is the action you are giving the user 
    # permission to do.
    # If you pass :manage it will apply to every action. Other common actions
    # here are :read, :create, :update and :destroy.
    #
    # The second argument is the resource the user can perform the action on. 
    # If you pass :all it will apply to every resource. Otherwise pass a Ruby
    # class of the resource.
    #
    # The third argument is an optional hash of conditions to further filter the
    # objects.
    # For example, here the user can only update published articles.
    #
    #   can :update, Article, :published => true
    #
    # See the wiki for details:
    # https://github.com/ryanb/cancan/wiki/Defining-Abilities
  end
end
