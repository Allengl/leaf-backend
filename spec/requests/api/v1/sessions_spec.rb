require 'rails_helper'

RSpec.describe "Seesions", type: :request do
  describe "会话" do
    it "登录（创建会话）" do
      User.create email: '1942813644@qq.com'
      post '/api/v1/session', params: {email: '1942813644@qq.com', code:'123456'}
      expect(response).to have_http_status(200)
      json = JSON.parse response.body
      expect(json['jwt']).to be_a String
    end
  end
end
