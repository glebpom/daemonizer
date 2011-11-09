module Spec
  module Path
    def gem_root
      File.expand_path('../../..', __FILE__)
    end

    def tmp_dir
      File.join(gem_root, '/tmp')
    end

    def app_root
      File.join(tmp_dir, "application")
    end

    extend self

  end
end
