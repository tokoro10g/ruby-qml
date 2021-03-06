require 'spec_helper'

describe QML::Dispatchable do
  class DispatchableFoo
    include QML::Dispatchable
    attr_accessor :value
  end

  describe '#later' do
    it 'queues a method call as a task to the dispatcher' do
      foo = DispatchableFoo.new
      foo.later.value = 'hoge'
      QML.application.process_events # wait for event loop hook to be enabled
      expect(foo.value).to be_nil
      QML.application.process_events
      expect(foo.value).to eq 'hoge'
    end
  end
end

[QML::Access, QML::QtObjectBase, QML::Data::ListModel].each do |mod|
  describe mod do
    it 'includes Dispatchable' do
      expect(mod.include?(QML::Dispatchable)).to eq true
    end
  end
end
