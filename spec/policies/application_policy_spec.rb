require 'spec_helper'

describe ApplicationPolicy do
  context "#as_json" do
    class JsonPolicy < ApplicationPolicy
      def initialize(allow)
        @allow = allow
      end

      def test
        @allow
      end

      def is_test?
        @allow
      end
    end

    subject { JsonPolicy.new(true) }

    it "generates hash with method names as keys" do
      expect(subject.as_json).to be_a(Hash)
    end

    it "gets only methods with question mark at the end" do
      expect(subject.as_json[:is_test]).to be_truthy
      expect(subject.as_json).not_to have_key(:test)
    end

    context "when method returns false" do
      subject { JsonPolicy.new(false) }
      it "skipped" do
        expect(subject.as_json).to be_blank
      end
    end
  end
end
