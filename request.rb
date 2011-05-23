# Encapsulates one request to the raplet, made by a particular user.
# Add your business logic here.
class Request

  attr_accessor :user, :params

  def initialize(user, params)
    @user, @params = user, params
  end

end
