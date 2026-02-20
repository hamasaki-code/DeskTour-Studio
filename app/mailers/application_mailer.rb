class ApplicationMailer < ActionMailer::Base
  default from: ENV.fetch("MAIL_FROM", "no-reply@desktourstudio.example")
  layout "mailer"
end
