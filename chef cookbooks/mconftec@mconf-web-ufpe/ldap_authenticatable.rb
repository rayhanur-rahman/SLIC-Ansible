require 'net/ldap'
require 'devise/strategies/authenticatable'

module Devise
  module Strategies
    class LdapAuthenticatable < Authenticatable

      def valid?
        # disable this auth method if not coming from the sessions controller
        # this strategy is called from other places as well, like after registering
        # leaving it enabled for all controllers can generate a few errors
        ldap_enabled? && params && params[:controller] == "sessions"
      end

      def authenticate!
        if ldap_enabled? and params[:user]
          Rails.logger.info "LDAP: LDAP is enabled, trying to connect to LDAP server"
          configs = ldap_configs
          ldap = ldap_connection(configs)
          ldap.auth(configs.ldap_user, configs.ldap_user_password)

          # Tries to bind to the ldap server
          begin
            bind_error = ldap_bind(ldap)
          rescue Net::LDAP::LdapError => e
            Rails.logger.error "LDAP: exception: #{e.inspect}"
            bind_error = :server_error
          end

          if bind_error
            case bind_error
            when :timeout
              Rails.logger.error "LDAP: authentication failed: timeout when trying to connect to the LDAP server"
              fail(I18n.t('devise.strategies.ldap_authenticatable.invalid_bind'))
            when :bind
              Rails.logger.error "LDAP: authentication failed: initial bind failed"
              fail(I18n.t('devise.strategies.ldap_authenticatable.invalid_bind'))
            when :server_error
              Rails.logger.error "LDAP: unknown server error or invalid response"
              fail(I18n.t('devise.strategies.ldap_authenticatable.invalid_bind'))
            end

          else
            Rails.logger.info "LDAP: trying to bind the target user: '#{login_from_params}'"

            # Tries to authenticate the user to the ldap server
            filter = ldap_filter(configs)
            Rails.logger.info "LDAP: filter: #{filter.inspect}"
            ldap_user = ldap.bind_as(:base => configs.ldap_user_treebase, :filter => filter, :password => password_from_params)

            unless ldap_user
              Rails.logger.error "LDAP: authentication failed: response: #{ldap_user}"
              Rails.logger.error "LDAP: error code: #{ldap.get_operation_result.code}"
              Rails.logger.error "LDAP: error message: #{ldap.get_operation_result.message}"
              fail(:invalid)

            else
              Rails.logger.info "LDAP: user successfully authenticated: #{ldap_user}"

              # For UFPE
              unless validate_user_group(ldap, ldap_user)
                Rails.logger.error "LDAP: the user doesn't belong to a group that has access to Mconf, aborting"
                return fail(:invalid)
              end

              ldap_helper = Mconf::LDAP.new(session)
              invalid_fields = ldap_helper.validate_user(ldap_user.first, configs)
              if invalid_fields
                case invalid_fields
                when :username
                  Rails.logger.error "LDAP: authentication failed: the user has no username set in the LDAP server"
                  fail(I18n.t('devise.strategies.ldap_authenticatable.missing_username'))
                when :name
                  Rails.logger.error "LDAP: authentication failed: the user has no name set in the LDAP server"
                  fail(I18n.t('devise.strategies.ldap_authenticatable.missing_name'))
                when :email
                  Rails.logger.error "LDAP: authentication failed: the user has no email set in the LDAP server"
                  fail(I18n.t('devise.strategies.ldap_authenticatable.missing_email'))
                end

              else
                # login or create the account
                user = ldap_helper.find_or_create_user(ldap_user.first, configs)
                if user.nil?
                  Rails.logger.error "LDAP: authentication failed: application wasn't able to create a new user"
                  fail(I18n.t('devise.strategies.ldap_authenticatable.create_failed'))
                else
                  if user.active_for_authentication?
                    ldap_helper.sign_user_in(user)
                    success!(user)
                  else
                    # throw the not_approved error that will take the user to the pending approval page
                    throw(:warden, message: :not_approved)
                  end

                end
              end
            end
          end

        # LDAP is not enabled in the site
        elsif not ldap_enabled?
          Rails.logger.info "LDAP: authentication via LDAP is not enabled"
          fail(I18n.t('devise.strategies.ldap_authenticatable.ldap_not_enabled'))
        else
          Rails.logger.info "LDAP: authentication failed: invalid user credentials"
          fail(:invalid)
        end
      end

      # Returns the login provided by user
      def login_from_params
        params[:user][:login]
      end

      # Returns the password provided by user
      def password_from_params
        params[:user][:password]
      end

      # Returns the model that stores the configurations for LDAP
      def ldap_configs
        Site.current
      end

      # Returns the filter to bind the user
      # Concatenates a base filter specified by an admin with the filter to match the
      # user. If the base filter is invalid or not specified, uses only the user filter.
      def ldap_filter(configs)
        base = nil
        unless configs.ldap_filter.blank?
          begin
            base = Net::LDAP::Filter.construct(configs.ldap_filter)
          rescue
            Rails.logger.info "LDAP: invalid base filter specified: #{configs.ldap_filter}"
            Rails.logger.info "LDAP: will use only the user/password filter"
          end
        end
        username = Net::LDAP::Filter.equals(configs.ldap_username_field, login_from_params)
        email = Net::LDAP::Filter.equals(configs.ldap_email_field, login_from_params)
        username_email = Net::LDAP::Filter.intersect(email, username)
        if base.nil?
          username_email
        else
          Net::LDAP::Filter.join(base, username_email)
        end
      end

      # Returns true if the ldap is enabled in Mconf Portal
      def ldap_enabled?
        ldap_configs.ldap_enabled?
      end

      # Creates the ldap variable to connect to ldap server.
      # Port 636 means LDAPS, so whe use encryption (simple_tls).
      # Otherwise there is no security (usually port 389).
      def ldap_connection(configs)
        if configs.ldap_port == 636
          Net::LDAP.new(:host => configs.ldap_host, :port => configs.ldap_port, :timeout => 10, :encryption => :simple_tls)
        else
          Net::LDAP.new(:host => configs.ldap_host, :port => configs.ldap_port, :timeout => 10)
        end
      end

      # Do the ldap server bind
      def ldap_bind(ldap)
        begin
          Timeout::timeout(10) do
            if ldap.bind
              Rails.logger.info "LDAP: succesfully binded to the LDAP server"
              nil
            else
              Rails.logger.error "LDAP: could not bind to the LDAP server, check your configurations"
              Rails.logger.error "LDAP: error code: #{ldap.get_operation_result.code}"
              Rails.logger.error "LDAP: error message: #{ldap.get_operation_result.message}"
              :bind
            end
          end
        rescue Timeout::Error => e
          Rails.logger.error "LDAP: the server did not respond in time, error: #{e}"
          :timeout
        end
      end

      # Check the groups the user belongs to, to make sure he belongs to the target
      # group to which our users should belong to have access to the app.
      def validate_user_group(ldap, ldap_user)
        configs = ldap_configs

        if configatron.ufpe.ldap_group.nil? || configatron.ufpe.ldap_group.blank?
          Rails.logger.error "LDAP: no group configured for UFPE, aborting."
          return false
        end
        Rails.logger.info "LDAP: set Mconf's LDAP group as: #{configatron.ufpe.ldap_group.to_s}"

        # Get the groups this user belongs to
        if ldap_user.first.nil? || ldap_user.first.try(:dn).blank?
          Rails.logger.error "LDAP: invalid DN for the user, aborting."
          return false
        end
        dn = ldap_user.first.dn

        Rails.logger.info "LDAP: checking groups for the user #{dn.inspect}"
        filter = "(&(objectClass=group)(member=#{dn}))"
        groups_user_belongs_to = [dn]
        ldap.search(base: configs.ldap_user_treebase, filter: filter) do |entry|
          Rails.logger.debug "LDAP: search for this user's groups got entry: #{entry.inspect}"
          if entry && entry.dn
            groups_user_belongs_to << entry.dn
          end
        end
        Rails.logger.info "LDAP: user belongs to the groups: #{groups_user_belongs_to.inspect}"

        # Get the groups that are members of out "g_mconf" group
        groups_member_of_g_mconf = ldap.search(base: configatron.ufpe.ldap_group)
        Rails.logger.debug "LDAP: search for members of Mconf's group got: #{groups_member_of_g_mconf.inspect}"
        if groups_member_of_g_mconf && groups_member_of_g_mconf.first && groups_member_of_g_mconf.first.member
          groups_member_of_g_mconf = groups_member_of_g_mconf.first.member
        else
          groups_member_of_g_mconf = []
        end
        Rails.logger.info "LDAP: groups member of Mconf's group: #{groups_member_of_g_mconf.inspect}"

        # Check if there is an intersection between the groups, otherwise the user
        # doesn't have permission to sign in
        group_intersection = groups_member_of_g_mconf & groups_user_belongs_to
        Rails.logger.info "LDAP: group intersection: #{group_intersection.inspect}"

        # Just in case a user has a "memberof" attribute set on him
        member_of_group = false
        if ldap_user.first.try(:memberof) && ldap_user.first.memberof.is_a?(Array)
          Rails.logger.info "LDAP: user has a 'memberof' attribute: #{ldap_user.first.memberof.inspect}"
          member_of_group = ldap_user.first.memberof.include?(configatron.ufpe.ldap_group)
        end

        Rails.logger.info "LDAP: user is direct member of group? #{member_of_group}"
        Rails.logger.info "LDAP: user is member of group through other groups? #{!group_intersection.empty?}"
        !group_intersection.empty? || member_of_group
      end

    end
  end
end

Warden::Strategies.add(:ldap_authenticatable, Devise::Strategies::LdapAuthenticatable)
