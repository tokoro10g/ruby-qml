require 'spec_helper'

describe QML::QtObjectBase do

  describe '#qml_eval' do

    let(:engine) { QML::Engine.new }
    let(:component) do
      QML::Component.new engine, data: <<-EOS
        import QtQuick 2.0
        QtObject {
          property string foo: 'foo'
          property string bar: 'bar'
        }
      EOS
    end
    let(:object) { component.create }
    let(:expression) { 'foo + bar' }
    let(:result) { object.qml_eval(expression) }

    it 'evaluates a JS expression in its QML scope' do
      expect(result).to eq 'foobar'
    end

    context 'when expression is wrong' do
      let(:expression) { 'hoge + piyo' }
      it 'raises QML::QMLError' do
        expect { result }.to raise_error(QML::QMLError)
      end
    end

    context 'when object does not belong to context' do
      let(:object) { QML::Plugins.test_util.createTestObject }
      it 'raises QML::QMLError' do
        expect { result }.to raise_error(QML::QMLError)
      end
    end
  end
end
