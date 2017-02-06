require 'cassandra'

class ClusterPassword < Cassandra::Auth::Providers::Password
	def initialize
		@username = 'iccassandra'
		@password = '0ecc769f04693a8af37f009c9a9320ca'
	end

	def create_authenticator(_)
		Authenticator.new(@username, @password)
    end
end