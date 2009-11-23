namespace :ci do
  task :copy_yml do
    system("cp #{Rails.root}/../../shared/yoga/* #{Rails.root}/config/")
  end

  desc "Prepare for CI and run entire test suite"
  task :build => ['ci:copy_yml', 'db:migrate', 'cucumber'] do
  end
end
