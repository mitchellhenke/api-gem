require File.dirname(__FILE__) + '/spec_helper.rb'

describe Bandsintown do
  it 'should have a module attr_accessor for @app_id' do
    expect(Bandsintown).to respond_to(:app_id)
    expect(Bandsintown).to respond_to(:app_id=)
  end
end
