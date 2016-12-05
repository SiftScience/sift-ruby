require_relative "../../../spec_helper"

require "sift/client/decision/validator"

module Sift
  class Client
    class Decision
      describe Validator do
        describe "#valid_order_configs?" do
          context "with valid configs" do
            it "where source is \"manual\" will return true" do
              validator = Validator.new(
                order_id: "1234",
                user_id: "2344",
                source: "manual",
                analyst: "foobar@example.com"
              )

              expect(validator.valid_order_configs?).to be(true)
            end

            it "where source is \"automated_rule\" will return true" do
              validator = Validator.new(
                order_id: "1234",
                user_id: "2344",
                source: "automated_rule"
              )

              expect(validator.valid_order_configs?).to be(true)
            end
          end

          context "with invalid configs" do
            it "will return a hash describing all the validation errors" do
            end
          end
        end
      end
    end
  end
end
