module API
  class Test < Grape::API
    version 'v1', using: :param # Define API::Version
    format :json # Define return format

    params do
      optional :password, type: String
    end

    helpers do
      def current_user_data(username, password)
        username = username.to_s; password = password.to_s; temp = {}
        page = Mechanize.new
        page.get "http://seat.ujn.edu.cn/rest/auth?username=#{username}&password=#{password}"

        data = JSON.parse(page.page.body)
        status = data['status']
        return { 'status': 'fail', 'data': nil } if status == 'fail'

        token = data['data']['token']
        page.get "http://seat.ujn.edu.cn/rest/v2/history/1/20?token=#{token}"
        data = JSON.parse(page.page.body)

        temp['status'] = data['status']; temp['data'] = data['data']['reservations']
        temp
      end
    end

    get '/user/:username/:password' do
      if params[:password].present?
        current_user_data(params[:username], params[:password])
      end
    end

    get '/user/:username' do
      current_user_data(params[:username], params[:username])
    end

  end

end
