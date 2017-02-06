require './ClusterHelper'

class DAO
  def initialize(clusterHelper)
    @clusterHelper = clusterHelper
  end

  def createSession
    @session = @clusterHelper.createSession()
    # Log for session creation
    puts "Session is created"
  end

  def closeSession
    @session.close()
    # Log for session close
    puts "Session is closed"
  end

  def getById(id)
    getByQuerySet(['dc_key',"#{id}"])
  end

  def getByQuerySet(querySet)
    createSession()
    resultSet = []
    @session.execute("select * from philadelphia where #{querySet[0]} = #{querySet[1]} allow filtering").each do |row|
      resultSet << row
    end
    closeSession()
    return resultSet 
  end
end