require 'spec_helper'

describe "test object" do

  let(:loader) { QML::PluginLoader.new QML::ROOT_PATH + 'ext/qml/plugins/testobject', 'rubyqml-testobject' }
  let(:obj) { loader.instance.createTestObject }

  describe '#normalMethod' do

    it 'should call the method' do
      expect(obj.normalMethod(1, "23")).to eq(24)
    end

    context 'if the arguments are not convertible' do
      it 'should raise error' do
        expect { obj.normalMethod([1, 2], 'bar') }.to raise_error QML::MethodError
      end
    end

    context 'if the number of arguments is wrong' do
      it 'should raise error' do
        expect { obj.normalMethod(1) }.to raise_error QML::MethodError
      end
    end
  end

  describe '#variantMethod' do

    it 'should call the method with QVariant arguments' do
      expect(obj.variantMethod(20, [1, 3, 4, 9])).to eq(37)
    end
  end

  describe '#overloadedMethod' do

    it 'should call the method with the same arity' do
      expect(obj.overloadedMethod('foo', 1)).to eq('2 params')
    end

    context 'when multiple methods with the same arity are provided' do

      it 'should call the method defined last' do
        expect(obj.overloadedMethod('hoge')).to eq('last')
      end
    end
  end

  describe '#emitSomeSignal' do

    it 'should emit the signal' do
      result = nil
      obj.someSignal.connect do |str|
        result = str
      end
      obj.emitSomeSignal('poyopoyo')
      expect(result).to eq 'poyopoyo'
      # spy = Ropework::SignalSpy.new(@obj.someSignal)
      # @obj.emitSomeSignal('poyopoyo')
      # expect(spy.args.first).to eq(['poyopoyo'])
    end
  end

  describe '#throwingMethod' do
    it 'raises a QML::CxxError' do
      expect { obj.throwingMethod }.to raise_error(QML::CppError, "<std::runtime_error> test error")
    end
  end

  describe '#metaObjectMethod' do
    it 'returns the QML::MetaObject of the test object' do
      expect(obj.metaObjectMethod).to eq obj.class.meta_object
    end
  end

  describe '#selfReturningMethod' do
    it 'returns the same Ruby object' do
      expect(obj.selfReturningMethod).to be obj
    end
  end

  describe 'name property' do

    it 'should be set' do
      obj.name = 'abcd'
      expect(obj.getName).to eq('abcd')
    end

    it 'should notify when changed' do
      spy = Ropework::SignalSpy.new(obj.name_changed)
      obj.name = 'hogepoyo'
      expect(spy.args.first).to eq(['hogepoyo'])
    end

    context 'with wrong type' do

      it 'raise error' do
        expect { obj.name = 123 }.to raise_error QML::PropertyError
      end
    end
  end

  describe 'enums' do
    
    it 'should be set' do
      k = obj.class
      expect(k::Apple).to eq(0)
      expect(k::Banana).to eq(1)
      expect(k::Orange).to eq(2)
    end
  end

  context 'in subclass' do
    let(:subobj) { loader.instance.createTestObject }
    it "can call TestObject's method" do
      expect(subobj.normalMethod(1, "23")).to eq(24)
    end
  end
end
