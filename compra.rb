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

timers.every(1800)  {
  agent.get(ENV['URL']) do |main_page|
    main_page.link_with(text: Regexp.new(ENV['TEXT_TO_LOOK_FOR'])) do |link|
      if (link != nil)
        puts link.text
        Mail.deliver do
          from ENV['GMAIL_MAIL']
          to ENV['GMAIL_MAIL']
          subject 'Sales opened'
          body 'Run!!'
        end
        return
      else
        puts "Not yet!"
      end
    end
  end
}

loop {timers.wait}
