# coding: utf-8

class ActiveRecord::Base

  def add_http(field)
    field = field.to_s
    value = self.send(field)
    if value and value !~ /^https?:\/\//
      self.attributes = {
        field => 'http://' + value
      } if value
    end
    true
  end

end
