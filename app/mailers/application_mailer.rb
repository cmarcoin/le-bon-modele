class ApplicationMailer < ActionMailer::Base
  default from: "Le Bon Modèle <contact@lebonmodele.fr>"
  layout "mailer"
  helper ApplicationHelper
end
