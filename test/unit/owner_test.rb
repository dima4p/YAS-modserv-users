require 'test_helper'

class OwnerTest < ActiveSupport::TestCase
  def test_validity
    owner = Owner.new(:type_type => Application)
    assert !owner.valid?
    
    #required
    owner.service_id = 1
    assert !owner.valid?
    
    #required
    owner.authorization_type = login
    assert !owner.valid?
    
    #valid service type
    owner.type_type = Service
    assert owner.valid?
  end
end
