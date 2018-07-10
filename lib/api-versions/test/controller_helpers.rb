module ApiVersions
  module Test
    module ControllerHelpers
      def routes(controller)
        before do
          controller_name = controller.to_s.underscore.chomp('_controller')
          Rails.application.routes.draw do
            match "test/:action", controller: controller_name, via: [:get, :post, :patch, :delete]
          end
        end

        after do
          Rails.application.reload_routes!
        end
      end
    end
  end
end
