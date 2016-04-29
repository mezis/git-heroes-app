require 'zeus/rails'

# ROOT_PATH = File.expand_path(Dir.pwd)
# ENV_PATH  = File.expand_path('spec/dummy/config/environment',  ROOT_PATH)
# BOOT_PATH = File.expand_path('spec/dummy/config/boot',  ROOT_PATH)
# APP_PATH  = File.expand_path('spec/dummy/config/application',  ROOT_PATH)
# ENGINE_ROOT = File.expand_path(Dir.pwd)
# ENGINE_PATH = File.expand_path('lib/my_engine/engine', ENGINE_ROOT)

class CustomPlan < Zeus::Rails

  # def my_custom_command
  #  # see https://github.com/burke/zeus/blob/master/docs/ruby/modifying.md
  # end

  def default_bundle
    super

    Zeus::LoadTracking.add_feature('./Gemfile.lock')
    Zeus::LoadTracking.add_feature('.env')
  end

  def test_environment
    super
    Zeus::LoadTracking.add_feature('.env.test')
  end
end

Zeus.plan = CustomPlan.new
