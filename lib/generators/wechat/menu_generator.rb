module Wechat
  module Generators
    class MenuGenerator < Rails::Generators::Base
      desc 'Generate wechat menu'
      source_root File.expand_path('../templates', __FILE__)
      class_option :conditional, desc: 'Generate conditional menu', type: :boolean, default: false

      def copy_menu
        if options.conditional?
          template 'config/wechat_menu_android.yml'
        else
          template 'config/wechat_menu.yml'
        end
      end

      def show_readme
        readme 'MENU_README' if behavior == :invoke
      end
    end
  end
end
