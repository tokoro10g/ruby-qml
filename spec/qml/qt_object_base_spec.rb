require 'spec_helper'

describe QML::QtObjectBase do

  describe '#qml_eval' do

    let(:component) do
      QML::Component.new data: <<-EOS
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

  describe 'ownership' do
    let(:ownership_test) { QML::Plugins.test_util.create_ownership_test }

    context 'when it is returned from a method' do
      it 'gets ownership of the object' do
        checker = -> { QML::TestUtil::ObjectLifeChecker.new(ownership_test.create_object) }.call
        QML.application.collect_garbage
        expect(checker.alive?).to eq false
      end
    end

    context 'when it is obtained from a property' do
      it 'does not get ownership of the object' do
        checker = -> { QML::TestUtil::ObjectLifeChecker.new(ownership_test.property_object) }.call
        QML.application.collect_garbage
        expect(checker.alive?).to eq true
      end
    end

    context 'when it has a parent' do
      it 'does not get ownership of the object' do
        checker = -> { QML::TestUtil::ObjectLifeChecker.new(ownership_test.sub_object) }.call
        QML.application.collect_garbage
        expect(checker.alive?).to eq true
      end
    end

    context 'when it is created by component' do
      let(:component) do
        QML::Component.new data: <<-EOS
          import QtQuick 2.0
          Item {}
        EOS
      end
      it 'gets ownership' do
        checker = -> { QML::TestUtil::ObjectLifeChecker.new(component.create) }.call
        QML.application.collect_garbage
        expect(checker.alive?).to eq false
      end
    end

    describe '#managed?' do
      [true, false].each do |cond|
        context "when managed = #{cond}" do
          it "returns #{cond}" do
            obj = ownership_test.create_object
            obj.managed = cond
            expect(obj.managed?).to eq cond
          end
        end
      end
    end

    context 'on garbage collection' do

      context 'when managed' do
        it 'gets destroyed' do
          checker = -> {
            obj = ownership_test.create_object
            obj.managed = true
            QML::TestUtil::ObjectLifeChecker.new(obj)
          }.call
          QML.application.collect_garbage
          expect(checker.alive?).to eq false
        end
      end

      context 'when not managed' do
        it 'does not get destroyed' do
          checker = -> {
            obj = ownership_test.create_object
            obj.managed = false
            QML::TestUtil::ObjectLifeChecker.new(obj)
          }.call
          QML.application.collect_garbage
          expect(checker.alive?).to eq true
        end
      end
    end
  end
end
