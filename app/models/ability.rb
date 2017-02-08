class Ability
  include CanCan::Ability

  def initialize(user)

    @site_ids = user.site_users.collect(&:site_id)

    # @owned_site_ids = user.sites.collect(&:id)
    # @shared_site_ids = user.site_users.collect(&:site_id) - @owned_site_ids

    can :favicon, Site
    
    if user
      # TODO: Make the distinction between managing a site you've created and 
      # managing a site you have access to.
      # What we're looking for here is probably 

      # can :deploy, Site, :id => @shared_site_ids
      # can :manage, SiteUser, :site_id => @shared_site_ids
      # can :manage, Site, :id => @owned_site_ids
      # This is probably going to need protected_attrtibutes in the controller to get perfect.

      can :manage, Site, :id => @site_ids
      can :manage, Version, :site_id => @site_ids

      can :create, Site do |site|
        user.sites.count < user.maximum_number_of_sites
      end

      can :create, Version
      can :manage, SiteUser, :site_id => @site_ids
    end
    can :public, Site

  end
end
