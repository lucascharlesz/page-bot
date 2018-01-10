require 'httparty'
require 'koala'
require 'twitter'
require 'byebug'
require 'json'
require 'dotenv/load'

class SocialManager
    def initialize
        # @access_token = HTTParty.get("https://graph.facebook.com/oauth/access_token?grant_type=fb_exchange_token&client_id=#{ENV['FB_APP_ID']}&client_secret=#{ENV["FB_APP_SECRET_KEY"]}&fb_exchange_token=#{ENV["FB_USER_ACCESS_TOKEN"]}")
    end

    def facebook_post(course)
        @graph = Koala::Facebook::API.new(ENV['60_D_TOKEN'])
        post_info = @graph.put_wall_post("Novo conteúdo na nossa plataforma EadBox! Para mais detalhes sobre o curso #{course['title']}, basta clicar no link! ", { link: "http://botapp.eadbox.com/cursos/#{course['course_slug']}" })
        
        return post_info['id']
    end
end