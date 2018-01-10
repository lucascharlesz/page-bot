require 'httparty'
require 'byebug'
require 'json'
require 'dotenv/load'
require './social_manager.rb'

class CoursesManager
    def initialize
        @published_courses = JSON.parse(File.read('published_courses.json'))
    end

    def fetch_courses
        begin
            retries ||= 0
            response = HTTParty.get(ENV['PLATFORM_URL'] + 'courses') 
            JSON.parse(response.body) || nil
        rescue => exception
            puts exception
            retry if (retries += 1) < 3
        end
    end

    def get_new_courses
        @published_courses.map do |published|
            @courses.keep_if { |course| course["course_id"] != published['course_id'] } 
        end

        return @courses
    end

    def save_published
        File.open('published_courses.json', 'w') { |file| file.write(@published_courses.to_json) }
    end

    def main
        while true do
            @courses = self.fetch_courses
            @new_courses = self.get_new_courses
            puts "Bucando novos cursos a cada #{ENV["FETCH_INTERVAL"]} segundos....."
            if @new_courses
                @new_courses.each do |course| 
                    puts "Novo curso encontrado! Publicando no facebook sobre o curso #{course['title']}"
                    post_id = SocialManager.new.facebook_post(course)
                    @published_courses.push( {'course_id' => course['course_id'], 'post_id' => post_id } )
                end
                self.save_published
            end
            sleep(ENV["FETCH_INTERVAL"].to_i)
        end
    end
end

CoursesManager.new.main