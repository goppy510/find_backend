#frozen_string_literal: true

begin
  def exec(command)
    `#{command}`
  end

  def get_options
    options = {}

    0.step(ARGV.count - 1, 1) do |i|
      case ARGV[i]
      when '--no-gemupdate'
        options[:no_gem_update] = true
      end
    end

    options
  end

  Dir.chdir(File.dirname($PROGRAM_NAME))
  env = ARGV[0]
  options = get_options
  case env
  when 'development'
    exec("cp config/settings/#{env}.yml config/settings.local.yml")
    unless options[:no_gem_update]
      exec('bundle install --path vendor/bundle --without production --clean')
      exec('bundle update')
    end
    exec("bundle exec rake db:create db:migrate db:seed RAILS_ENV=#{env}")
    exec("bundle exec rake test_data:generate")
  when 'test'
    exec("cp config/settings/test.yml config/settings.local.yml")
    exec('bundle install --path vendor/bundle --without production --clean')
    exec('bundle update')
    exec('bundle exec rake db:create db:migrate db:seed RAILS_ENV=test')
    exec('bundle exec rake test_data:generate')
  else
    puts 'Usage: ' + File.basename(__FILE__) + ' [development|test]'
  end
rescue
  puts 'Usage: ' + File.basename(__FILE__) + ' [development|test]'
end
