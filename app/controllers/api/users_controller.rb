class Api::UsersController < ApplicationController
  def new; end

  def create
    path = 'users'
    @user = http_post(
      path,
      user_params["uid"],
      user_params["nickname"],
    )
    redirect_to root_path
  end

  private

  def http_post(path, uid, nickname)
    uri = URI.parse("https://library-nippo.herokuapp.com/#{path}")
    headers = { 'Authorization' => 'Bearer secret_key' }

    params = {
      'role' => '1',
      'uid' => uid,
      'nickname' => nickname,
    }

    begin
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      http.open_timeout = 5
      http.read_timeout = 10

      request = Net::HTTP::Post.new(uri.request_uri, headers)
      request.set_form_data(params)

      response = http.request(request)

      case response
      when Net::HTTPSuccess
        JSON.parse(response.body)
      when Net::HTTPRedirection
        'redirect'
      else
        'else'
      end

    rescue IOError => e
      logger.error(e.message)
    rescue TimeoutError => e
      logger.error(e.message)
    rescue JSON::ParserError => e
      logger.error(e.message)
    rescue => e
      logger.error(e.message)
    end
  end

  def user_params
    params.permit(:nickname, :uid)
  end

end
