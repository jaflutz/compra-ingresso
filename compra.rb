require 'mechanize'
require 'timers'
require 'mail'

agent = Mechanize.new
timers = Timers::Group.new

options = {
            :address              => "smtp.gmail.com",
            :port                 => 587,
            :user_name            => ENV['GMAIL_MAIL'],
            :password             => ENV['GMAIL_PASSWORD'],
            :authentication       => 'plain',
            :enable_starttls_auto => true
}


Mail.defaults do
    delivery_method :smtp, options
end

agent.pluggable_parser.default = Mechanize::Download

timers.every(900)  {
  begin
  agent.get(ENV['URL']) do |main_page|
    main_page.link_with(text: Regexp.new(ENV['TEXT_TO_LOOK_FOR'])) do |link|
      if (link != nil)
        puts link.text + " - " + Time.now.to_s
        Mail.deliver do
          from ENV['GMAIL_MAIL']
          to ENV['GMAIL_MAIL']
          subject 'Sales opened'
          body 'Run!!'
        end
        return
      else
        puts "Not yet! -" + Time.now.to_s
      end
    end
  end
  rescue
    puts "Net failed - " + Time.now.to_s
  end
}

loop {timers.wait}
