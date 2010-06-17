# coding: utf-8

class ActiveRecord::Base

  def space_trim(field)
    field = field.to_s
    value = self.send(field)
    self.attributes = {
      field => value.gsub(/([\n\r\t])/su, ' ').gsub(/^( +)/, '').gsub(/( +)$/, '').gsub(/(  +)/, ' ')
    } if value
    true
  end

end
