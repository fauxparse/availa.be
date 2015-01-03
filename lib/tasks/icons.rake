namespace :icons do
  desc "Generate custom icon font"
  task :compile do
    puts "Compiling icons..."
    puts %x(bundle exec fontcustom compile)
  end
end
