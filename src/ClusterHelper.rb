require './ClusterPassword'

class ClusterHelper
  def initialize
    credentials = { :hosts => ["35.165.190.142", "35.165.233.35", "35.161.144.48"],
                    :datacenter => 'AWS_VPC_US_WEST_2',
                    :auth_provider => ClusterPassword.new() 
                  }
    @cluster = Cassandra.cluster(credentials)
    # Log for cluster hosts
    @cluster.each_host do |host|
      puts "Datacenter: #{host.datacenter}; Host: #{host.ip} ; Rack: #{host.rack}"
    end
  end

  def createSession
    @cluster.connect('crime_incidents')
  end
end