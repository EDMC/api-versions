module ApiVersions
  module Generators
    class BumpGenerator < Rails::Generators::Base
      desc "Bump API version to next version, initializing controllers"
      source_root File.expand_path('../templates', __FILE__)

      def get_controllers
        Dir.chdir File.join(Rails.root, 'app', 'controllers') do
          @controllers = Dir.glob('api/v**/**/*.rb')
        end

        @highest_version = @controllers.map do |controller|
          controller.match(/api\/v(\d+?)\//)[1]
        end.max

        @controllers.keep_if { |element| element =~ /api\/v#{@highest_version}\// }
      end

      def generate_new_controllers
        @controllers.each do |controller|
          new_controller = controller.gsub /api\/v#{@highest_version}\//, "api/v#{@highest_version.to_i + 1}/"
          @current_new_controller = new_controller.chomp(File.extname(controller)).camelize
          @current_old_controller = controller.chomp(File.extname(controller)).camelize
          template 'controller.rb', File.join('app', 'controllers', new_controller)
        end
      end
    end
  end
end
