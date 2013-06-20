class JobLog < ActiveRecord::Base
  belongs_to :job

  def update_log(text)
    text += "\n" unless text["\n"]
    update_attribute(:log_text, log_text + text)
  end
end
