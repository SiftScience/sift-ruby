require_relative "../../spec_helper"

require "sift/validate/decision"

module Sift
  module Validate
    describe Decision do
      describe "#valid_user?" do
        it "will return true" do
          validator = Decision.new(
            user_id: "hello world",
            source: :hello_world,
            analyst: "asdfsadf@heyo.com"
          )

          expect(validator.valid_user?).to be(true)
        end

        it "with invalid user_id, will return false" do
          validator = Decision.new(order_id: "asfasdf")
          expect(validator.valid_user?).to be(false), "nil user is valid"

          validator = Decision.new(order_id: "asfasdf", user_id: {})
          expect(validator.valid_user?).to be(false), "user hash is valid"

          validator = Decision.new(order_id: "asfasdf", user_id: /werwer/)
          expect(validator.valid_user?).to be(false), "regex user is valid"
        end
      end

      describe "#valid_order?" do
        it "will return true with valid configs" do
          validator = Decision.new(
            order_id: "order_foo_bar_12354",
            user_id: "hello world",
            source: :hello_world,
            analyst: "asdfsadf@heyo.com"
          )

          expect(validator.valid_order?).to be(true)
        end

        context "with invalid params:" do
          it "user_id, will return false" do
            validator = Decision.new(order_id: "asfasdf")
            expect(validator.valid_order?).to be(false), "nil user is valid"

            validator = Decision.new(order_id: "asfasdf", user_id: {})
            expect(validator.valid_order?).to be(false), "user hash is valid"

            validator = Decision.new(order_id: "asfasdf", user_id: /werwer/)
            expect(validator.valid_order?).to be(false), "regex user is valid"
          end

          it "order_id, will return false" do
            validator = Decision.new(user_id: 1235)
            expect(validator.valid_order?).to be(false)

            validator = Decision.new(user_id: 1235, order_id: {})
            expect(validator.valid_order?).to be(false)

            validator = Decision.new(user_id: 1235, order_id: /23424/)
            expect(validator.valid_order?).to be(false)
          end
        end
      end

      describe "#error_messages" do
        it "will return an array of error messages" do
          validator = Decision.new

          error_message =
            "#{Primitive::ERROR_MESSAGES[:non_empty_string]}, got NilClass"

          validator.valid_order?

          expect(validator.error_messages).to contain_exactly(
            "order_id #{error_message}",
            "user_id #{error_message}"
          )
        end
      end
    end
  end
end
